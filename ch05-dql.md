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
大家好，歡迎來到第五章——DQL 資料查詢語言！

DQL（Data Query Language）就只有一個指令：SELECT。但別小看這一個指令——它的變化非常豐富，是整個 SQL 學習中最重要、也用得最多的部分。

我們在前幾章建立了資料庫結構，現在終於要開始「問資料庫問題」了！

學完這章，大家就能從資料庫裡查詢出各種想要的資料。
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
這章的內容比較多，但都是環環相扣的。

我們先學最基本的 SELECT * 和欄位選擇，再加入各種條件篩選，然後學排序和分組，最後說分頁查詢。

每個部分我都會給完整的 SQL 範例，大家跟著練習一遍，很快就能上手。

最後的「執行順序」部分特別重要——了解 SQL 子句的執行順序，才能避免很多初學者常見的錯誤。
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
  is_active TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

範例資料包含：手機、筆電、平板等電子產品，分屬「手機」、「電腦」、「配件」三個類別，價格從 299 到 49,999 不等。

<!--
在開始學 SELECT 之前，先讓大家了解我們要查詢的資料表結構。

products 表包含商品 ID、名稱、類別、價格、庫存、是否上架。

這是一個很常見的電商商品表結構，大家應該很容易有直覺感受。

接下來所有的 SELECT 範例，都會在這張表上示範。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第一部分
# SELECT 基礎

<!--
進入第一部分，從最基本的 SELECT 開始。

SELECT 就是「問資料庫：給我什麼資料」。
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
SELECT * 是最簡單的查詢，但在正式環境裡要避免使用。

為什麼？想像你的 products 表有 50 個欄位，但你的頁面只需要顯示名稱和價格。SELECT * 會把 50 個欄位都傳給應用程式，其中 48 個欄位都是浪費。

別名（AS）讓查詢結果的欄位名稱更易讀，特別是在有計算或函式的情況下很有用，例如 SELECT price * 0.9 AS discounted_price。

⚠️ AS 關鍵字可以省略：SELECT name product_name FROM products 和 SELECT name AS product_name 效果相同，但加上 AS 可讀性更好。
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
DISTINCT 的使用場景很直觀：當你想知道某個欄位有哪些不同的值時使用。

例如：你有一張有 10,000 筆商品的 products 表，想知道這些商品分屬哪些類別，你不需要看全部 10,000 筆，只需要 SELECT DISTINCT category FROM products，就能快速得到所有類別的清單。

注意最後一個例子：DISTINCT 作用於所有指定欄位的「組合」，不是每個欄位分開去重。SELECT DISTINCT category, is_active 會回傳 (手機, 1)、(手機, 0)、(電腦, 1) 這樣的組合，每個唯一的組合只出現一次。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第二部分
# WHERE — 條件篩選

<!--
進入第二部分：WHERE 篩選。

WHERE 就是「給資料庫下條件」，告訴它我們只要滿足某些條件的資料。
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
WHERE 的運算子和我們在數學、程式語言裡學的很類似。

要特別注意「不等於」的寫法：SQL 標準是 <>，但 MySQL 也支援 !=（和大多數程式語言一樣）。兩種寫法都對。

AND 和 OR 的優先順序：AND 的優先級比 OR 高。WHERE a = 1 OR b = 2 AND c = 3 會被解讀為 WHERE a = 1 OR (b = 2 AND c = 3)。如果想要 (a = 1 OR b = 2) AND c = 3，必須明確加括號。

⚠️ 這是初學者常犯的邏輯錯誤，加括號讓條件的優先級清晰，永遠是好習慣。
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
這幾個進階篩選語法是日常工作中非常常用的。

IN 可以取代多個 OR 條件。WHERE category = '手機' OR category = '平板' 等同於 WHERE category IN ('手機', '平板')，後者更簡潔。

BETWEEN 包含邊界值。WHERE price BETWEEN 1000 AND 5000 等同於 WHERE price >= 1000 AND price <= 5000。

LIKE 的萬用字元：% 代表任意數量的任意字元，_ 代表恰好一個任意字元。WHERE name LIKE 'iPhone%' 會找到 "iPhone 15", "iPhone 15 Pro" 等；WHERE name LIKE 'iPhone_' 只會找到 "iPhone 1", "iPhone X" 等後面恰好一個字元的名稱。

⚠️ LIKE '%pattern%' 開頭用 % 的模糊查詢沒辦法使用索引（Full Index Scan），資料量大時會很慢。
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
這是一個綜合了多個 WHERE 條件的查詢範例。

BETWEEN 1000 AND 10000：篩選出中價位商品。
stock > 0：確保有庫存，沒庫存的商品顯示給使用者沒意義。
is_active = 1：只顯示上架的商品。

這三個條件用 AND 連接，代表三個條件都要同時成立。

在電商系統裡，類似這樣的查詢非常常見——例如「商品列表頁：顯示有庫存的上架商品，按照某個條件篩選」。

⚠️ 注意縮排：多個 AND 條件時，每個條件另起一行並縮排，這讓 SQL 更容易閱讀和維護。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第三部分
# ORDER BY 排序與 LIMIT

<!--
進入第三部分，學習排序和限制筆數。

這兩個是日常查詢裡非常常用的語法，讓結果「有秩序」而且「數量可控」。
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
ORDER BY 的語法很直觀：ASC（Ascending）是升冪（小到大），DESC（Descending）是降冪（大到小）。

預設是 ASC，所以 ORDER BY price 和 ORDER BY price ASC 效果相同。

多欄位排序的執行邏輯：先按第一個欄位排，如果第一個欄位的值相同，再按第二個欄位排。在這個例子裡：先把所有商品按類別排列（手機、平板、電腦...），同一類別的商品再按價格從高到低排列。

⚠️ MySQL 8.x 注意：舊版本 MySQL 5.7 中，GROUP BY 有隱式排序的特性（GROUP BY 的欄位會自動排序）。MySQL 8.x 取消了這個特性，如果需要排序，必須明確加 ORDER BY。
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
LIMIT 是分頁查詢的基礎。幾乎所有需要列表頁面的 Web 應用都會用到它。

分頁邏輯的計算：
- 第 1 頁（page=1）：LIMIT 10 OFFSET 0
- 第 2 頁（page=2）：LIMIT 10 OFFSET 10
- 第 3 頁（page=3）：LIMIT 10 OFFSET 20
- 第 n 頁：LIMIT 10 OFFSET (n-1)*10

注意兩種寫法的差異：LIMIT 10 OFFSET 20 和 LIMIT 20, 10 效果相同，但要注意後者的順序是「offset, count」，和你想的可能相反！建議用明確的 LIMIT ... OFFSET ... 寫法，更易讀。

⚠️ LIMIT OFFSET 分頁在資料量大時有效能問題：OFFSET 1000000 要先跳過一百萬筆資料才能取出下一頁，很慢。大資料量的分頁應考慮使用「基於 ID 的分頁」（Keyset Pagination）。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第四部分
# GROUP BY 與 HAVING

<!--
進入這章最重要的部分：GROUP BY 和 HAVING。

GROUP BY 讓我們能夠對資料進行「分組統計」，是做報表和分析最常用的語法。

我保證用一個具體的例子讓大家秒懂。
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
聚合函式是對一組資料做計算，回傳一個摘要值。

這些函式在沒有 GROUP BY 時，作用於整張表（或 WHERE 篩選後的結果）。

COUNT 有兩種用法，差別很重要：
COUNT(*) 計算所有行，包括某些欄位是 NULL 的行。
COUNT(description) 只計算 description 欄位不是 NULL 的行。

如果你想知道「有幾個商品有填寫描述」，就用 COUNT(description)；如果想知道「總共有幾個商品」，就用 COUNT(*)。

⚠️ 如果 SELECT 裡有聚合函式，那麼沒有被聚合的欄位，必須出現在 GROUP BY 子句裡（除非確定這個欄位在每組裡的值都一樣）。
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
GROUP BY 的邏輯很直觀：先把所有商品按 category 分組，然後對每一組分別計算 COUNT、AVG、MAX、MIN。

想像你手上有一堆商品的清單，先把手機、電腦、平板分成三堆，然後分別統計每一堆裡有幾個商品、平均價格是多少。GROUP BY 做的就是這件事。

注意 WHERE 和 GROUP BY 的順序：WHERE 在 GROUP BY 之前執行，先篩掉下架商品，再做分組統計。

ORDER BY 在 GROUP BY 之後：先分組計算出 avg_price，再按 avg_price 排序。

⚠️ MySQL 8.x 中，GROUP BY 不再自動排序。如果你想讓結果按 category 排序，必須明確加 ORDER BY category。
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
HAVING 是初學者最容易搞錯的地方，讓我說清楚 WHERE 和 HAVING 的差別：

WHERE：在分組之前篩選——把每一列的原始資料過濾，只留下 is_active = 1 的商品。
HAVING：在分組之後篩選——對每一個分組的統計結果過濾，只留下 COUNT(*) > 10 的類別。

一個常見的問題是：可以用 HAVING price > 1000 嗎？
可以，但不推薦。這樣 MySQL 要先把所有資料分組，再篩掉每一組裡 price <= 1000 的資料——這非常沒效率。應該把這個條件放在 WHERE 裡，讓它在分組前就先過濾掉。

原則：能放 WHERE 的條件就放 WHERE，只有針對分組結果的條件才放 HAVING。
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
這張投影片非常重要，建議大家截圖或抄下來。

撰寫順序是你在鍵盤上打字的順序。
執行順序是 MySQL 內部處理的順序。

為什麼 WHERE 不能用 SELECT 定義的別名？因為 WHERE 比 SELECT 先執行——WHERE 在執行的時候，別名還沒有被定義出來。

為什麼 ORDER BY 可以用別名？因為 ORDER BY 在 SELECT 之後執行，此時別名已經存在了。

為什麼 HAVING 能用聚合函式，但 WHERE 不能？因為 GROUP BY（和聚合計算）在 WHERE 之後、HAVING 之前執行。WHERE 執行時，聚合結果還沒有被計算出來。

理解這個執行順序，是寫出正確複雜查詢的關鍵。
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
學完這章，大家已經能夠寫出各種 SELECT 查詢了。

最重要的兩個觀念：
1. WHERE 和 HAVING 的差別：WHERE 篩選原始列，HAVING 篩選分組結果
2. 執行順序：FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT

下一章 DML 會用到今天學的 SELECT，特別是 INSERT ... SELECT 的語法。

先做兩道練習，把今天的內容鞏固！
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
第一題考驗 WHERE + ORDER BY + LIMIT 的組合。

提示：日期篩選可以用 BETWEEN 或 YEAR(order_date) = 2024。

第二題考驗 GROUP BY + HAVING + 日期函式。

提示：用 YEAR(order_date)、MONTH(order_date) 做分組，或用 DATE_FORMAT(order_date, '%Y-%m') 格式化年月。
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
解答分析：

題目一：
- BETWEEN '2024-01-01' AND '2024-12-31' 是日期範圍篩選。注意日期要用字串格式，MySQL 會自動轉換。
- ORDER BY amount DESC：金額大到小。
- LIMIT 10：只取前 10 筆。

題目二：
- GROUP BY YEAR(order_date), MONTH(order_date)：按年月分組。兩個欄位都要列在 GROUP BY 裡。
- HAVING COUNT(*) > 100：篩選訂單數超過 100 的月份。這用 HAVING 而不是 WHERE，因為 COUNT(*) 是聚合結果。
- ORDER BY year, month：讓結果按時間順序排列。

⚠️ MySQL 8.x 要注意：GROUP BY 不再自動排序，一定要明確加 ORDER BY。
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
這題故意設計成讓大家深思 WHERE 和 HAVING 的差別。

提示：想想 WHERE 和 HAVING 各自在什麼時候執行？

查詢 A 的 WHERE price > 1000 是對原始列篩選，然後再分組統計。
查詢 B 是先對所有商品分組統計，再用 HAVING 篩選平均價格超過 1000 的類別。

這兩個查詢的結果會不同！你能說出差別在哪裡嗎？
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
這是一個很好的思考題，能幫助大家深刻理解 WHERE 和 HAVING 的差異。

假設有一個「手機」類別，包含 5 支手機：
- iPhone 15 Pro：39,900
- iPhone 15：28,900
- 紅米 Note 13：4,999
- 紅米 12：2,499
- 小米 13T：13,999

查詢 A（WHERE price > 1000）：先篩掉所有 price ≤ 1000 的商品（假設都沒有），然後計算「手機」類別的統計。COUNT 就是 5，AVG 是全部的平均。

查詢 B（HAVING AVG > 1000）：先計算「手機」類別所有商品的 COUNT=5 和 AVG，然後判斷 AVG 是否超過 1000。

如果有一個「配件」類別，裡面有很多小配件，均價是 500，則查詢 B 會過濾掉「配件」類別，但查詢 A 不一定（取決於是否有 price ≤ 1000 的配件）。

理解這個差別，你就真的掌握了 WHERE 和 HAVING 的本質。
-->

---
layout: end
---

# Q & A

有任何問題嗎？

<!--
現在開放 Q&A 時間。

大家對 DQL 有沒有什麼疑問？

最容易搞混的三個地方：
1. WHERE vs HAVING
2. 子句的執行順序
3. GROUP BY 後面為什麼要列出 SELECT 中所有非聚合欄位

歡迎現在提問。下一章我們要開始學怎麼「新增、修改、刪除」資料！
-->
