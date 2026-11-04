---
theme: penguin
class: text-center
highlighter: shiki
lineNumbers: true
drawings:
  persist: false
transition: slide-left
title: DQL 資料查詢語言
routeAlias: ch05
style: |
  .slidev-layout p,
  .slidev-layout li,
  .slidev-layout td,
  .slidev-layout th,
  .slidev-layout div {
    font-size: max(16px, 1em);
  }
  table {
    width: 100%;
    margin: 1rem 0;
    border-collapse: collapse;
  }
  th, td {
    padding: 8px !important;
    border: 1px solid #e2e8f0 !important;
  }
  .index-table td {
    text-align: center;
    font-family: monospace;
  }
---

<div class="flex flex-col justify-center items-center h-full" style="background: #ffffff;">
  <p style="color: #5eada0; font-size: 1rem; font-weight: 600; letter-spacing: 0.2em; text-transform: uppercase; margin-bottom: 1.2rem;">
    MySQL 資料庫課程
  </p>
  <h1 style="color: #1a5c5c; font-size: 3.8rem; font-weight: 900; line-height: 1.15; margin-bottom: 1.5rem;">
    DQL 資料查詢語言
  </h1>
  <div style="height: 4px; width: 320px; background: linear-gradient(90deg, #5eada0, #a7d9d0); border-radius: 2px; margin-bottom: 1.5rem;"></div>
  <p style="color: #4a7c7c; font-size: 1.15rem; font-style: italic;">
    「問對問題，才能找到答案」
  </p>
  <Link to="home" style="color: #9dc4c4; font-size: 0.85rem; margin-top: 2rem; text-decoration: none; letter-spacing: 0.05em;">← 返回目錄</Link>
</div>

<!--
大家好，歡迎來到第五章：DQL 資料查詢語言。

上一章我們把資料表建好了，可是資料存進去，最終還是要拿出來用。商品列表、銷售報表、搜尋結果，背後都是一個查詢。

DQL 只有一個指令，就是 SELECT。別看它只有一個，它的變化非常多，也是整個 SQL 裡最常用的部分。學完這章，大家就能從資料表裡，精準查出自己想要的資料。
-->

---
layout: default
---

# Outline

- **SELECT 基礎** — 查詢欄位、別名、DISTINCT
- **WHERE 篩選** — 條件運算子、AND/OR/NOT、IN、BETWEEN、LIKE
- **ORDER BY 排序** — 升冪、降冪、多欄排序
- **GROUP BY 分組** — 搭配聚合函式，HAVING 篩選分組
- **LIMIT / OFFSET** — 限制回傳筆數、分頁查詢
- **完整 SELECT 執行順序** — 子句的執行順序

<!--
這一章我們會一層一層把查詢組起來。先學最基本的 SELECT，選欄位、取別名、去除重複。接著用 WHERE 篩選資料，再用 ORDER BY 排序、用 LIMIT 做分頁。然後是最重要的 GROUP BY 分組統計和 HAVING。最後整理所有子句的執行順序，這是避開很多錯誤的關鍵。
-->

---

# 範例資料表

本章的 SQL 範例都基於以下資料表：

```sql
CREATE TABLE products (
  id       INT AUTO_INCREMENT PRIMARY KEY,
  name     VARCHAR(200) NOT NULL,
  category VARCHAR(100) NOT NULL,
  price    DECIMAL(10,2) NOT NULL,
  stock    INT NOT NULL DEFAULT 0,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  description TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

範例資料包含：手機、筆電、平板等電子產品，分屬「手機」、「電腦」、「配件」三個類別，價格從 299 到 49,999 不等。

<!--
在開始查詢之前，先認識一下這章要用的資料表。

這是一張很常見的電商商品表 `products`，有商品編號、名稱、分類、價格、庫存、是否上架，以及商品描述。`is_active` 是 1 代表上架中，0 代表已下架。`description` 可以不填，沒填的時候就是 NULL。

資料裡有手機、筆電、平板這些電子產品，分成手機、電腦、配件三個分類，價格從兩百多元到將近五萬元都有。

接下來這一章的 SELECT 範例，都會在這張表上示範。大家可以先記住這幾個欄位的名稱，後面看範例時會更容易跟上。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第一部分
# SELECT 基礎

<!--
我們從最基本的 SELECT 開始。它做的事情很簡單，就是問資料庫：請給我這些資料。
-->

---

# SELECT 基本語法

「SELECT 是 SQL 最核心的指令，用來從資料表中取出我們需要的欄位。」

```sql
-- 查詢所有欄位
SELECT * FROM products;

-- 查詢特定欄位
SELECT name, price FROM products;

-- 使用別名（AS）讓欄位名稱更易讀
SELECT
  name     AS product_name,
  price    AS unit_price,
  stock    AS inventory
FROM products;
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>效能提示：</b>避免在正式環境使用 SELECT *，應明確列出需要的欄位。SELECT * 會取回所有欄位，包括不需要的，浪費網路傳輸和記憶體。
</div>

<!--
「SELECT 是 SQL 最核心的指令，用來從資料表中取出我們需要的欄位。」

第一個寫法是 `SELECT *`，星號代表全部欄位，執行後會列出商品表的所有欄位。第二個寫法是只列出 `name` 和 `price`，結果就只有名稱和價格兩欄。

第三個寫法用了 `AS` 取別名。執行後，結果的欄位標題會變成 `product_name`、`unit_price` 這些我們取的名字。別名在有計算的時候特別好用，例如把價格乘以零點九，取名叫折扣價。

要提醒的是，正式環境裡最好避免 `SELECT *`。假設商品表有五十個欄位，頁面只需要名稱和價格，星號會把用不到的四十八個欄位也一起傳回來，浪費網路和記憶體。
-->

---

# DISTINCT — 去除重複值

「DISTINCT 讓查詢結果中的重複值只出現一次。」

查詢 products 表中有哪些商品類別：

```sql
-- 沒有 DISTINCT：可能顯示大量重複的 category
SELECT category FROM products;

-- 使用 DISTINCT：每個類別只顯示一次
SELECT DISTINCT category FROM products;

-- DISTINCT 作用於所有指定欄位的組合
SELECT DISTINCT category, is_active FROM products;
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>適用場景：</b>快速了解某個欄位有哪些不同的值，例如「這張表裡有哪些類別？」、「有哪些不同的狀態？」
</div>

<!--
「DISTINCT 讓查詢結果中的重複值只出現一次。」

想像商品表裡有一萬筆商品，我們只想知道總共有哪些分類。第一個查詢沒有 DISTINCT，會回傳一萬筆分類，大部分都重複。第二個查詢加了 `DISTINCT`，執行後每個分類只會出現一次，馬上就得到一份分類清單。

第三個查詢要特別注意。當 DISTINCT 後面接兩個欄位，它是看兩個欄位的「組合」是否重複，而不是每個欄位各自去重。所以結果可能會有手機加上架、手機加下架、電腦加上架，每一種組合出現一次。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第二部分
# WHERE — 條件篩選

<!--
能把資料查出來之後，下一步是篩選。WHERE 就是幫資料庫下條件，只留下我們要的資料。
-->

---

# WHERE 基本運算子

WHERE 子句支援各種比較和邏輯運算子：

| 運算子 | 說明 | 範例 |
| --- | --- | --- |
| `=` | 等於 | `WHERE price = 999` |
| `<>` 或 `!=` | 不等於 | `WHERE category <> '電腦'` |
| `>`, `<`, `>=`, `<=` | 大於、小於等 | `WHERE price > 1000` |
| `AND` | 且（兩個條件都要成立）| `WHERE price > 100 AND stock > 0` |
| `OR` | 或（任一條件成立即可）| `WHERE category = '手機' OR category = '平板'` |
| `NOT` | 非（條件反轉）| `WHERE NOT is_active = 0` |

<!--
表格列出了 WHERE 常用的運算子，跟我們在數學裡學的很像。

不等於有兩種寫法。SQL 的標準寫法是小於加大於的 `<>`，MySQL 也接受驚嘆號等號的 `!=`，兩種都可以。

比較需要注意的是 AND 和 OR 混在一起的時候。AND 的優先順序比 OR 高。例如條件寫成「a 等於 1 OR b 等於 2 AND c 等於 3」，MySQL 會先算後面的 AND，再跟前面做 OR。

如果我們的本意是先算 OR，就一定要自己加上括號。這是初學者很常犯的邏輯錯誤，所以條件一複雜，就養成加括號的習慣，讓意思一目了然。
-->

---

# WHERE 的進階篩選

| 運算子 | 說明 | 範例 |
| --- | --- | --- |
| `IN (...)` | 值在清單中 | `WHERE category IN ('手機', '平板')` |
| `NOT IN (...)` | 值不在清單中 | `WHERE id NOT IN (1, 2, 3)` |
| `BETWEEN a AND b` | 值在範圍內（含頭尾）| `WHERE price BETWEEN 1000 AND 5000` |
| `LIKE '%pattern%'` | 模糊比對 | `WHERE name LIKE '%iPhone%'` |
| `IS NULL` | 值是 NULL | `WHERE description IS NULL` |
| `IS NOT NULL` | 值不是 NULL | `WHERE return_date IS NOT NULL` |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
⚠️ <b>常見錯誤：</b>比較 NULL 必須用 <code>IS NULL</code>，不能用 <code>= NULL</code>。<code>WHERE description = NULL</code> 永遠找不到任何資料！
</div>

<!--
這頁是幾個進階的篩選方式，在日常工作中非常常用。

`IN` 可以取代一串 OR。分類是手機或平板，直接寫 `category IN ('手機', '平板')`，簡潔很多。`BETWEEN` 是範圍篩選，而且頭尾都包含，一千到五千就包含一千和五千本身。

`LIKE` 是模糊比對。百分比符號代表任意長度的任意字元，底線代表剛好一個字元。所以 `'iPhone%'` 會找到所有 iPhone 開頭的商品。

最後是 NULL。比較 NULL 一定要用 `IS NULL`，寫成等於 NULL 永遠查不到資料，這在第一章就提過了。

另外要注意，百分比放在開頭的模糊查詢用不到索引，資料一多就會很慢。
-->

---

# WHERE 篩選 — 完整範例

查詢價格在 1000 到 10000 之間、且有庫存的上架商品：

```sql
SELECT
  id,
  name,
  category,
  price,
  stock
FROM products
WHERE
  price BETWEEN 1000 AND 10000
  AND stock > 0
  AND is_active = 1;
```

執行後，你會看到符合三個條件的商品列表：價格在合理範圍內、還有庫存、且目前上架中。

<!--
我們把剛才學的條件組合起來，查出價格在一千到一萬之間、有庫存、而且上架中的商品。

這三個條件分別是 `price BETWEEN 1000 AND 10000`、`stock > 0` 和 `is_active = 1`，中間用 AND 連起來，代表三個條件要同時成立。

執行後，我們會得到一份中價位、有貨、正在販售的商品清單。電商網站的商品列表頁，背後通常就是類似這樣的查詢。

另外大家可以注意排版。條件一多的時候，每個條件各自換行、加上縮排，讀起來會清楚很多，之後要增減條件也比較方便。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第三部分
# ORDER BY 排序與 LIMIT

<!--
篩選完資料，接著要讓結果有順序、數量也能控制。我們來學 ORDER BY 和 LIMIT。
-->

---

# ORDER BY — 排序結果

「ORDER BY 讓查詢結果按照指定欄位排序。」

```sql
-- 依價格升冪排序（預設 ASC）
SELECT name, price FROM products
ORDER BY price;

-- 依價格降冪排序
SELECT name, price FROM products
ORDER BY price DESC;

-- 多欄位排序：先按類別升冪，同類別再按價格降冪
SELECT name, category, price FROM products
ORDER BY category ASC, price DESC;

-- 依別名排序
SELECT name, price * 0.9 AS sale_price FROM products
ORDER BY sale_price DESC;
```

<!--
「ORDER BY 讓查詢結果按照指定欄位排序。」`ASC` 是由小到大，`DESC` 是由大到小，沒寫的話預設是 ASC。

前兩個範例分別依價格由低到高、由高到低排列。

第三個範例是多欄位排序，邏輯是先依第一個欄位排，第一個欄位相同時，才看第二個欄位。所以執行後，商品會先按分類排在一起，同一個分類裡，再依價格由高到低排。

最後一個範例是用別名排序。我們先算出九折的 `sale_price`，再直接拿這個別名來排序，這是可以的。為什麼可以，我們在這章最後講執行順序時會說明。
-->

---

# LIMIT 與 OFFSET — 分頁查詢

「LIMIT 限制回傳的最大筆數，OFFSET 跳過前 N 筆。」

```sql
-- 只取前 10 筆
SELECT name, price FROM products
ORDER BY price DESC
LIMIT 10;

-- 跳過前 20 筆，取接下來的 10 筆（第 3 頁，每頁 10 筆）
SELECT name, price FROM products
ORDER BY price DESC
LIMIT 10 OFFSET 20;

-- 簡寫方式（LIMIT offset, count）
SELECT name, price FROM products
ORDER BY price DESC
LIMIT 20, 10;
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>分頁公式：</b><code>OFFSET = (page_number - 1) × page_size</code>。第 1 頁 OFFSET=0，第 2 頁 OFFSET=10，第 3 頁 OFFSET=20。
</div>

<!--
「LIMIT 限制回傳的最大筆數，OFFSET 跳過前 N 筆。」這兩個合起來，就是分頁查詢的基礎。

第一個範例只取價格最高的前十筆。第二個範例跳過前二十筆，再取十筆，也就是每頁十筆時的第三頁。分頁的公式就是畫面下方那一行，頁碼減一，再乘上每頁筆數。

第三個是簡寫，`LIMIT 20, 10` 和第二個效果一樣。要小心它的順序是先寫跳過幾筆、再寫取幾筆，很容易寫反，所以建議用明確的 OFFSET 寫法。

另外，OFFSET 很大的時候，MySQL 還是得先數過前面所有資料，頁數越後面就越慢。資料量很大時，實務上會改用以 ID 為基準的分頁方式。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第四部分
# GROUP BY 與 HAVING

<!--
接下來是這章最重要的部分。GROUP BY 讓我們做分組統計，是報表和分析最常用的語法。
-->

---

# 聚合函式（Aggregate Functions）

GROUP BY 通常搭配聚合函式使用，對每組資料做計算：

| 函式 | 說明 | 範例 |
| --- | --- | --- |
| `COUNT(*)` | 計算筆數 | `SELECT COUNT(*) FROM products` |
| `COUNT(col)` | 計算非 NULL 的筆數 | `SELECT COUNT(description) FROM products` |
| `SUM(col)` | 加總 | `SELECT SUM(price) FROM products` |
| `AVG(col)` | 平均值 | `SELECT AVG(price) FROM products` |
| `MAX(col)` | 最大值 | `SELECT MAX(price) FROM products` |
| `MIN(col)` | 最小值 | `SELECT MIN(price) FROM products` |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>COUNT(*) vs COUNT(col)：</b>COUNT(*) 計算所有列數（含 NULL）；COUNT(col) 只計算該欄位不是 NULL 的列數。
</div>

<!--
在學分組之前，先認識聚合函式。它們會把一堆資料，算成一個摘要數字。表格裡有計數的 `COUNT`、加總的 `SUM`、平均的 `AVG`，以及最大值 `MAX`、最小值 `MIN`。沒有搭配分組時，它們會對整張表，或是 WHERE 篩選後的結果做計算。

這裡最需要分清楚的是 COUNT 的兩種寫法。`COUNT(*)` 算的是總共有幾列，不管欄位是不是 NULL。`COUNT(description)` 只算有填描述的那些列。

所以想知道總共有幾個商品，用 `COUNT(*)`。想知道有幾個商品填了描述，就用 `COUNT(description)`。
-->

---

# GROUP BY — 分組統計

「GROUP BY 把資料按照某個欄位的值分組，再對每一組做聚合計算。」

查詢每個類別的商品數量和平均價格：

```sql
SELECT
  category,
  COUNT(*)        AS product_count,
  AVG(price)      AS avg_price,
  MAX(price)      AS max_price,
  MIN(price)      AS min_price
FROM products
WHERE is_active = 1
GROUP BY category
ORDER BY avg_price DESC;
```

執行後，你會看到每個類別一筆資料，顯示各類別的商品統計。

<!--
「GROUP BY 把資料按照某個欄位的值分組，再對每一組做聚合計算。」

想像桌上有一堆商品卡片，我們先依分類分成手機、電腦、配件三堆，再分別數數看每一堆有幾張、平均價格多少。GROUP BY 做的就是這件事。

這段查詢先用 `WHERE is_active = 1` 篩掉下架商品，再 `GROUP BY category` 分組，對每組算出數量、平均、最高和最低價格，最後依平均價格排序。

執行後，每個分類會得到一列統計結果。

另外，SELECT 裡沒有被聚合的欄位，像這裡的 `category`，必須出現在 GROUP BY 裡。還有，MySQL 8 的 GROUP BY 不會自動排序，需要排序就要明確寫 ORDER BY。
-->

---

# HAVING — 篩選分組結果

「HAVING 是 GROUP BY 的過濾器，篩選出符合條件的分組。」

「WHERE 篩選的是原始資料的每一列；HAVING 篩選的是分組後的摘要結果。」

查詢商品數量超過 10 項、且平均價格大於 5000 的類別：

```sql
SELECT
  category,
  COUNT(*)   AS product_count,
  AVG(price) AS avg_price
FROM products
WHERE is_active = 1
GROUP BY category
HAVING COUNT(*) > 10 AND AVG(price) > 5000
ORDER BY avg_price DESC;
```

<!--
「HAVING 是 GROUP BY 的過濾器，篩選出符合條件的分組。」

這也是初學者最容易搞混的地方。關鍵就在畫面上那句話：「WHERE 篩選的是原始資料的每一列；HAVING 篩選的是分組後的摘要結果。」

在這段查詢裡，WHERE 先在分組之前，把下架商品排除掉。分組統計完之後，HAVING 再把商品數量不到十個、或平均價格不到五千的分類過濾掉。執行後，只會留下又多又貴的分類。

那可不可以把價格條件寫在 HAVING 裡呢？可以，但很沒效率，因為 MySQL 會先把所有資料分組，最後才過濾。

所以原則是，能放在 WHERE 的條件就放 WHERE，只有針對分組結果的條件才放 HAVING。
-->

---

# 完整 SELECT 子句順序

SELECT 語句的子句必須按照以下順序撰寫：

```sql
SELECT   column1, aggregate_func(column2)   -- 3. 選取欄位
FROM     table_name                          -- 1. 來源
WHERE    row_condition                       -- 2. 篩選原始列
GROUP BY grouping_column                     -- 4. 分組
HAVING   group_condition                     -- 5. 篩選分組
ORDER BY sort_column [ASC|DESC]              -- 6. 排序
LIMIT    n OFFSET m;                         -- 7. 限制筆數
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>執行順序（與撰寫順序不同）：</b>FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT。理解執行順序，才能理解為什麼 WHERE 不能用 SELECT 的別名，但 ORDER BY 可以。
</div>

<!--
這一頁非常重要。程式碼上的編號，代表 MySQL 真正執行的順序，和我們書寫的順序並不一樣。

我們寫的時候是 SELECT 開頭，可是 MySQL 會先處理 FROM，找到資料來源。接著是 WHERE 篩選，然後 GROUP BY 分組，HAVING 篩選分組。到這裡，才執行 SELECT 選出欄位，最後是 ORDER BY 排序和 LIMIT 限制筆數。

理解這個順序，很多問題就有答案了。WHERE 為什麼不能用 SELECT 的別名？因為 WHERE 執行的時候，別名還沒產生。ORDER BY 為什麼可以？因為它在 SELECT 之後。WHERE 為什麼不能用 COUNT 這類聚合函式？因為那時候還沒分組，聚合結果還沒算出來。
-->

---

# 總結

本章學了 DQL 資料查詢語言的核心語法：

- **SELECT** — 指定欄位，用 AS 設定別名，DISTINCT 去除重複
- **WHERE** — 條件篩選：`=`、`<>`、`BETWEEN`、`IN`、`LIKE`、`IS NULL`
- **ORDER BY** — ASC 升冪、DESC 降冪，支援多欄位排序
- **GROUP BY** — 分組統計，搭配 COUNT、SUM、AVG、MAX、MIN
- **HAVING** — 篩選分組後的結果（不是原始列）
- **LIMIT / OFFSET** — 限制筆數，實作分頁

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
🚀 <b>下一章：</b>我們將學習 DML——用 INSERT、UPDATE、DELETE 對資料進行新增、修改和刪除操作！
</div>

<!--
我們整理一下這章的重點。SELECT 選出欄位，可以用 AS 取別名、用 DISTINCT 去除重複。WHERE 篩選原始資料，ORDER BY 排序，LIMIT 和 OFFSET 做分頁。GROUP BY 搭配聚合函式做分組統計，HAVING 篩選分組後的結果。

其中最關鍵的兩個觀念，一個是 WHERE 和 HAVING 的差別，另一個是子句的執行順序。

接下來我們先做兩題練習。下一章，我們會學怎麼新增、修改和刪除資料。
-->

---
layout: default
---

# 練習 1：任務說明
### 分析訂單資料

假設你有以下資料表：

```sql
CREATE TABLE orders (
  id          INT PRIMARY KEY AUTO_INCREMENT,
  customer_id INT NOT NULL,
  amount      DECIMAL(10,2) NOT NULL,
  status      VARCHAR(20) NOT NULL,
  order_date  DATE NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**任務：**
1. 查詢 2024 年的訂單，只顯示 `completed` 狀態的，按金額降冪排序，取前 10 筆
2. 統計每個月的訂單數量和總金額，只顯示訂單數量超過 100 的月份

<!--
第一題，我們用一張訂單表來練習分析。任務有兩個。第一個是找出 2024 年、狀態是 completed 的訂單，依金額由高到低排序，只取前十筆。第二個是統計每個月的訂單數量和總金額，只顯示訂單數量超過一百筆的月份。

思考一下，第二題篩選的是每個月的統計數字，那這個條件應該寫在 WHERE，還是 HAVING？

我們先暫停一下，自己寫寫看。

【講師】給大家十分鐘，可以提示日期函式 YEAR 和 MONTH 的用法。
-->

---
layout: default
---

# 練習 1：解題提示

```sql
-- 題目一：2024 年已完成訂單，金額前 10
SELECT id, customer_id, amount, order_date
FROM orders
WHERE status = 'completed'
  AND order_date BETWEEN '2024-01-01' AND '2024-12-31'
ORDER BY amount DESC
LIMIT 10;

-- 題目二：每個月訂單統計，只顯示超過 100 筆的月份
SELECT
  YEAR(order_date)  AS year,
  MONTH(order_date) AS month,
  COUNT(*)          AS order_count,
  SUM(amount)       AS total_amount
FROM orders
GROUP BY YEAR(order_date), MONTH(order_date)
HAVING COUNT(*) > 100
ORDER BY year, month;
```

<!--
我們來看解答。

第一題是 WHERE、ORDER BY 和 LIMIT 的組合。條件裡用 `BETWEEN` 篩選 2024 年整年的日期，日期寫成字串，MySQL 會自動轉換。接著依金額由大到小排序，最後 `LIMIT 10` 取前十筆。執行後會得到 2024 年金額最高的十筆完成訂單。

第二題回答了剛才的思考題。我們用 `YEAR` 和 `MONTH` 兩個函式，依年月分組，算出每個月的筆數和總金額。超過一百筆這個條件，是針對分組後的統計結果，所以要用 `HAVING COUNT(*) > 100`，而不是 WHERE。

最後別忘了 `ORDER BY year, month`，讓結果依時間排列，因為 MySQL 8 的 GROUP BY 不會自動幫我們排序。
-->

---
layout: default
---

# 練習 2：任務說明
### 找出 WHERE vs HAVING 的差別

以下兩個 SQL 查詢，結果是否相同？為什麼？

```sql
-- 查詢 A
SELECT category, COUNT(*) AS cnt, AVG(price) AS avg_price
FROM products
WHERE price > 1000
GROUP BY category;

-- 查詢 B
SELECT category, COUNT(*) AS cnt, AVG(price) AS avg_price
FROM products
GROUP BY category
HAVING AVG(price) > 1000;
```

**思考：** 這兩個查詢各自的含義是什麼？結果會一樣嗎？

<!--
第二題是一個思考題。畫面上有兩個查詢，看起來很像，都在依分類統計商品數量和平均價格。

差別在於，查詢 A 用 WHERE 篩選價格大於一千，查詢 B 用 HAVING 篩選平均價格大於一千。

請大家想想看，這兩個查詢的意思分別是什麼？執行結果會一樣嗎？

可以從執行順序來思考，WHERE 和 HAVING 分別是在分組之前還是之後執行？

我們先暫停一下，想清楚再看答案。

【講師】給大家三到五分鐘，可以請幾位同學說說自己的判斷。
-->

---
layout: default
---

# 練習 2：解題提示

**結果不同！**

| 面向 | 查詢 A（WHERE price > 1000）| 查詢 B（HAVING AVG > 1000）|
| --- | --- | --- |
| 先做什麼 | 先篩掉 price ≤ 1000 的商品 | 先統計所有商品 |
| COUNT 計算什麼 | 只計算 price > 1000 的商品數 | 計算該類別的全部商品數 |
| AVG 計算什麼 | 只計算 price > 1000 的商品均價 | 計算所有商品的均價 |
| 篩選目標 | 列出包含 1000+ 商品的各類別統計 | 列出整體均價超過 1000 的類別 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>結論：</b>WHERE 影響「哪些資料參與統計」，HAVING 影響「哪些統計結果被回傳」。
</div>

<!--
答案是結果不同，我們用一個例子來看。

假設配件分類裡有十個商品，其中八個是幾百元的小配件，兩個是三千元的耳機。

查詢 A 先用 WHERE 把一千元以下的商品排除，只剩兩副耳機參與統計。所以配件會出現在結果裡，數量是二，平均價格是三千。

查詢 B 則是先統計全部十個商品，平均價格可能只有幾百元，接著 HAVING 判斷平均沒有超過一千，整個配件分類就被過濾掉了。

所以結論是，WHERE 決定「哪些資料參與統計」，HAVING 決定「哪些統計結果被回傳」。
-->

---
layout: end
---

# Q & A

有任何問題嗎？

<!--
今天我們從最基本的 SELECT 出發，一路學到 WHERE 篩選、排序分頁，以及 GROUP BY 和 HAVING 的分組統計。

最容易搞混的有三個地方：WHERE 和 HAVING 的差別、子句的執行順序，以及 SELECT 裡沒有被聚合的欄位都要列進 GROUP BY。這三點掌握了，查詢就能寫得又對又快。

下一章，我們要學怎麼新增、修改和刪除資料。我們下一章見。

【講師】開放提問，可以從 WHERE 和 HAVING 的差別開始引導。
-->
