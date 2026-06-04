---
theme: penguin
class: text-center
highlighter: shiki
lineNumbers: true
drawings:
  persist: false
transition: slide-left
title: 子查詢與進階查詢
routeAlias: ch10
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
    子查詢與進階查詢
  </h1>
  <div style="height: 4px; width: 320px; background: linear-gradient(90deg, #5eada0, #a7d9d0); border-radius: 2px; margin-bottom: 1.5rem;"></div>
  <p style="color: #4a7c7c; font-size: 1.15rem; font-style: italic;">
    「查詢裡面再放查詢，一次解決複雜問題」
  </p>
  <Link to="home" style="color: #9dc4c4; font-size: 0.85rem; margin-top: 2rem; text-decoration: none; letter-spacing: 0.05em;">← 返回目錄</Link>
</div>

<!--
大家好，歡迎來到第十章——子查詢與進階查詢！

前幾章我們學了 SELECT、JOIN、GROUP BY 等基礎查詢。但有時候，你想回答的問題用一個 SELECT 搞不定。

例如：「找出訂單金額高於平均值的顧客」——你需要先算出平均值，再拿這個平均值來篩選。這就需要用到子查詢（Subquery）。

這章我們會學子查詢的各種用法，包括 IN、LIKE 進階用法、EXISTS，以及相關子查詢（Correlated Subquery）。學完後，你能解決更複雜的業務查詢需求。
-->

---
layout: default
---

# Outline

- **什麼是子查詢？** — 概念與使用場景
- **LIKE 進階用法** — 萬用字元 `%` 與 `_`、ESCAPE
- **IN / NOT IN 與子查詢** — 搭配子查詢做條件篩選
- **EXISTS / NOT EXISTS** — 「存在性」判斷，相關子查詢
- **子查詢的位置** — 出現在 SELECT、FROM、WHERE 的子查詢
- **子查詢 vs JOIN** — 效能比較與選擇原則

<!--
這章有六個部分，每部分聚焦一個概念。

LIKE 雖然在 DQL 章節提過，但這裡會深入說萬用字元的細節和效能問題。

IN 和 EXISTS 是最常用的兩種子查詢形式，我們會仔細比較它們的差別和使用場景。

最後說子查詢 vs JOIN 的效能比較，這是實際工作中很常見的選擇問題。
-->

---

# 範例資料表

本章使用電商訂單系統：

```sql
CREATE TABLE customers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE orders (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  amount      DECIMAL(10,2) NOT NULL,
  status      VARCHAR(20) NOT NULL DEFAULT 'pending',
  order_date  DATE NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE products (
  id       INT AUTO_INCREMENT PRIMARY KEY,
  name     VARCHAR(200) NOT NULL,
  category VARCHAR(100) NOT NULL,
  price    DECIMAL(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

<!--
這三張表就是本章所有範例的基礎：customers（顧客）、orders（訂單）、products（商品）。

資料的設計：
- 一個顧客可以有多筆訂單（一對多）
- 訂單有狀態（pending、completed、cancelled）
- 商品有類別和價格

這樣的電商系統非常貼近真實場景，讓大家在學習語法的同時，也能感受到實際的業務應用。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第一部分
# 什麼是子查詢？

<!--
進入第一部分，先說清楚什麼是子查詢，以及它適合解決什麼樣的問題。
-->

---

# 什麼是子查詢？

「子查詢（Subquery）是寫在另一個 SQL 語句內部的 SELECT 語句，用括號包住，用來提供外層查詢所需的值或條件。」

**沒有子查詢時的做法（兩步驟）：**

```sql
-- 步驟一：先查平均金額
SELECT AVG(amount) FROM orders;  -- 結果：1500.00

-- 步驟二：拿結果手動帶入
SELECT * FROM orders WHERE amount > 1500.00;
```

**有子查詢：一步完成**

```sql
SELECT * FROM orders
WHERE amount > (SELECT AVG(amount) FROM orders);
```

<!--
子查詢解決的問題很直觀：「我需要先得到某個計算結果，再把這個結果用在查詢條件裡。」

沒有子查詢時，你要分兩步走：先查出平均值，再手動把數字帶入另一個查詢。這不只麻煩，而且如果資料更新了，你的手動帶入的值就過時了。

有了子查詢，MySQL 會自動先執行括號裡的子查詢，得到結果，再把這個結果用在外層的 WHERE 條件。

這讓你的 SQL 可以「動態地」根據當前資料做計算，而不是把計算結果寫死在 SQL 裡。
-->

---

# 子查詢的種類

子查詢依照回傳的資料形式，分成三種：

| 種類 | 說明 | 適用運算子 |
| --- | --- | --- |
| **純量子查詢** | 回傳單一值（一列一欄）| `=`, `>`, `<`, `>=`, `<=` |
| **列子查詢** | 回傳一列多欄 | `=`（搭配 ROW）|
| **表子查詢** | 回傳多列多欄（結果集）| `IN`, `NOT IN`, `EXISTS`, FROM 子句 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>最常用的是「純量子查詢」和「表子查詢」：</b>純量子查詢搭配比較運算子，表子查詢搭配 IN 或 EXISTS。
</div>

<!--
子查詢按照它回傳什麼資料形式來分類。

純量子查詢回傳的是一個數字或一個字串——例如 AVG(amount) 的結果是一個數字。你可以用 = 或 > 來比較一個欄位和這個純量。

表子查詢回傳的是一個「結果集」，有多列多欄。你不能直接用 > 比較一個欄位和一個結果集，而是要用 IN（「是否在這個集合裡」）或 EXISTS（「這個集合是否不為空」）。

舉例說明：
- 「找出訂單金額高於平均值的訂單」→ 純量子查詢（AVG 回傳一個值）
- 「找出下過 completed 訂單的顧客」→ 表子查詢（子查詢回傳多個 customer_id）
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第二部分
# LIKE 進階用法

<!--
進入第二部分：LIKE 的進階用法。

LIKE 在 DQL 章節介紹過基礎用法，這裡我們深入說萬用字元的細節，以及一些常見的效能陷阱。
-->

---

# LIKE 的萬用字元

「LIKE 是模糊比對運算子，`%` 代表任意長度的任意字元，`_` 代表恰好一個任意字元。」

| 模式 | 說明 | 符合的範例 |
| --- | --- | --- |
| `'iPhone%'` | 以 iPhone 開頭 | iPhone 15, iPhone 15 Pro |
| `'%手機%'` | 包含「手機」 | 智慧手機, 舊手機殼 |
| `'%Pro'` | 以 Pro 結尾 | iPhone 15 Pro, iPad Pro |
| `'iPhone_5'` | iPhone 後接一字元再接 5 | iPhone 15, iPhoneX5 |
| `'___'` | 恰好三個字元 | abc, 台灣省 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
⚠️ <b>效能警告：</b>以 <code>%</code> 開頭的模式（如 <code>'%keyword%'</code>）無法使用 B-Tree 索引，資料量大時會做全表掃描！
</div>

<!--
LIKE 的萬用字元很直觀，但有一個效能問題要特別注意。

% 和 _ 的差別：
- % 可以匹配零個或多個任意字元：'A%' 可以匹配 'A', 'AB', 'ABC'...
- _ 只能匹配恰好一個字元：'A_' 只能匹配 'AB', 'AC', 'A1'... 不能匹配 'A' 或 'ABC'

效能問題：
'iPhone%'（前綴搜尋）可以使用 B-Tree 索引，因為索引是按字首排序的，MySQL 能快速定位到 'iPhone' 開頭的資料。

'%iPhone%'（中間或後綴搜尋）無法使用索引，因為 MySQL 不知道從哪裡開始找。它只能掃描整張表的每一列，逐一比較。

如果你的應用需要大量的中間/後綴搜尋，考慮使用 FULLTEXT 索引或 Elasticsearch。
-->

---

# LIKE 範例

查詢商品名稱包含特定關鍵字：

```sql
-- 前綴搜尋（可使用索引，效率好）
SELECT name, price FROM products
WHERE name LIKE 'iPhone%';

-- 關鍵字搜尋（無法使用索引，全表掃描）
SELECT name, price FROM products
WHERE name LIKE '%Pro%';

-- NOT LIKE：排除特定模式
SELECT name, price FROM products
WHERE name NOT LIKE '%二手%'
  AND category = '手機';

-- ESCAPE：搜尋包含 % 或 _ 的字串
SELECT * FROM products
WHERE description LIKE '50\% off' ESCAPE '\';
```

<!--
這四個範例涵蓋了 LIKE 最常用的模式。

前綴搜尋 'iPhone%' 是效能最好的寫法，應盡量使用。

'%Pro%' 的關鍵字搜尋雖然效能差，但在資料量不大的表上仍然可以接受。問題是當資料量增長到幾百萬筆時，這個查詢會變得非常慢。

NOT LIKE 搭配 AND 可以做複合條件篩選——這裡同時篩選「不是二手商品」且「類別是手機」。

ESCAPE 是個比較少見但重要的語法：如果你要搜尋的字串本身包含 % 或 _ 這些萬用字元，就需要用 ESCAPE 指定一個轉義字符，讓 LIKE 把 % 當成普通字符而不是萬用字元。

⚠️ 要注意大小寫：MySQL 的 LIKE 在 utf8mb4_general_ci 等 case-insensitive 校對規則下不區分大小寫。如果需要區分，要用 LIKE BINARY 或切換到 case-sensitive 的校對規則。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第三部分
# IN / NOT IN 與子查詢

<!--
進入第三部分：IN 和 NOT IN 搭配子查詢的用法。

IN 是最常見的子查詢形式，讓我們先複習 IN 的基本用法，再說搭配子查詢的進階應用。
-->

---

# IN 的基本用法

「IN 判斷一個欄位的值是否在指定的清單中。」

```sql
-- IN 搭配靜態清單
SELECT name, category, price
FROM products
WHERE category IN ('手機', '平板', '電腦');

-- NOT IN 排除特定值
SELECT name, category, price
FROM products
WHERE category NOT IN ('配件', '二手');

-- IN 等同於多個 OR（但更簡潔）
-- WHERE category = '手機' OR category = '平板' OR category = '電腦'
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>IN vs OR：</b>當選項超過 2–3 個時，IN 比多個 OR 更易讀，效能也可能更好（MySQL 可以對 IN 清單做最佳化）。
</div>

<!--
IN 的基本用法大家在 DQL 章節已經學過了，這裡快速複習一下。

IN ('A', 'B', 'C') 等同於 = 'A' OR = 'B' OR = 'C'，但更簡潔。

NOT IN 是 IN 的反向：「排除清單裡的所有值」。

一個重要的陷阱：NOT IN 和 NULL 的相互作用。
如果 IN 的清單裡包含 NULL，NOT IN 的結果可能讓你意外。例如：
WHERE category NOT IN ('手機', NULL)
這個查詢不會回傳任何結果！因為 MySQL 用 AND NOT (category = '手機' OR category = NULL) 來計算，而 category = NULL 永遠是 NULL（不是 TRUE 也不是 FALSE），導致整個條件無法成立。

這是後面我們說「NOT IN 和 NOT EXISTS 的差別」的重要背景知識。
-->

---

# IN 搭配子查詢

「IN 的清單不只可以是靜態值，也可以是子查詢的結果。」

查詢下過 completed 訂單的顧客：

```sql
-- 第一種寫法：IN 搭配子查詢
SELECT id, name, email
FROM customers
WHERE id IN (
  SELECT customer_id
  FROM orders
  WHERE status = 'completed'
);
```

子查詢先執行，回傳所有 `completed` 訂單的 `customer_id` 清單，然後外層的 `WHERE id IN (...)` 篩選出這些顧客。

<!--
這是 IN 搭配子查詢最典型的用法。

執行邏輯：
1. MySQL 先執行括號裡的子查詢：SELECT customer_id FROM orders WHERE status = 'completed'
2. 得到一個 customer_id 的清單，例如 (1, 3, 5, 7)
3. 然後執行外層查詢：SELECT ... FROM customers WHERE id IN (1, 3, 5, 7)

這個查詢等同於用 JOIN 實現：
SELECT DISTINCT c.id, c.name FROM customers c INNER JOIN orders o ON c.id = o.customer_id WHERE o.status = 'completed'

兩種寫法效果相同，我們後面會比較它們的效能。
-->

---

# NOT IN 搭配子查詢

「NOT IN 搭配子查詢，找出「在某表中沒有對應記錄」的資料。」

查詢從未下過訂單的顧客：

```sql
SELECT id, name, email
FROM customers
WHERE id NOT IN (
  SELECT customer_id
  FROM orders
);
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
⚠️ <b>NULL 陷阱：</b>如果子查詢的結果包含 NULL（orders.customer_id 允許 NULL），NOT IN 會回傳空結果！應改用 NOT EXISTS 或 LEFT JOIN + IS NULL。
</div>

<!--
NOT IN 搭配子查詢是一個常見的寫法，但有一個嚴重的 NULL 陷阱。

問題出在：如果 orders.customer_id 允許 NULL 值，而 orders 表裡有一筆 customer_id = NULL 的訂單，那麼子查詢就回傳了 (1, 3, 5, NULL)。

MySQL 在執行 WHERE id NOT IN (1, 3, 5, NULL) 時，會把它展開成：
WHERE id != 1 AND id != 3 AND id != 5 AND id != NULL

而 id != NULL 永遠是 NULL（不是 TRUE），所以整個條件就是 NULL，不會回傳任何行。

這個 Bug 很隱蔽，因為平時可能沒有 customer_id = NULL 的資料，一切正常；但某天出現了這樣的資料，查詢就突然不對了。

安全的替代方案：
1. 確保子查詢的欄位設了 NOT NULL
2. 用 NOT EXISTS（不受 NULL 影響）
3. 用 LEFT JOIN + IS NULL
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第四部分
# EXISTS / NOT EXISTS

<!--
進入第四部分：EXISTS 和 NOT EXISTS。

EXISTS 是和 IN 並列最重要的子查詢形式，但它的邏輯和 IN 有根本上的不同。理解了這個差別，才能在對的場景選對工具。
-->

---

# 什麼是 EXISTS？

「EXISTS 不關心子查詢回傳什麼資料，只關心子查詢是否回傳了至少一列。如果是，就回傳 TRUE。」

```sql
-- IN 版本（先取出所有 customer_id，再比對）
SELECT name FROM customers
WHERE id IN (
  SELECT customer_id FROM orders WHERE status = 'completed'
);

-- EXISTS 版本（對每個顧客，問「這個顧客有 completed 訂單嗎？」）
SELECT name FROM customers c
WHERE EXISTS (
  SELECT 1 FROM orders o
  WHERE o.customer_id = c.id
    AND o.status = 'completed'
);
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>EXISTS 常寫 SELECT 1：</b>因為 EXISTS 只在乎「有沒有結果」，所以子查詢 SELECT 什麼欄位不重要，慣例寫 SELECT 1 表示「我只是確認存在，不需要欄位」。
</div>

<!--
EXISTS 和 IN 的核心差別：

IN 是「取清單，再對照」：先執行子查詢得到一個清單，再把外層每一列的欄位和這個清單比對。

EXISTS 是「逐一問問題」：對外層查詢的每一列，執行一次子查詢，問「這一列對應的相關資料存在嗎？」如果子查詢回傳至少一列，EXISTS 就是 TRUE，這一列就保留。

注意 EXISTS 版本裡的 o.customer_id = c.id——它引用了外層查詢的 c.id。這種「子查詢引用外層查詢欄位」的模式叫做「相關子查詢」（Correlated Subquery）。

EXISTS 的一個好處：因為只需要找到一列就夠了，MySQL 找到第一個符合條件的行就立刻停止，不需要把所有符合的行都找出來（短路求值）。
-->

---

# NOT EXISTS

「NOT EXISTS 當子查詢回傳空結果時為 TRUE，用來找出「沒有對應記錄」的資料。」

查詢從未下過訂單的顧客（NOT EXISTS 版本，無 NULL 問題）：

```sql
SELECT id, name, email
FROM customers c
WHERE NOT EXISTS (
  SELECT 1 FROM orders o
  WHERE o.customer_id = c.id
);
```

| 比較 | NOT IN | NOT EXISTS |
| --- | --- | --- |
| NULL 問題 | ⚠️ 子查詢含 NULL 時回傳空結果 | ✅ 不受 NULL 影響 |
| 語義 | 值不在清單中 | 相關子查詢回傳空結果 |
| 建議使用時機 | 子查詢欄位確定無 NULL | 子查詢欄位可能有 NULL 時 |

<!--
NOT EXISTS 是解決 NOT IN NULL 陷阱的推薦替代方案。

為什麼 NOT EXISTS 不受 NULL 影響？

NOT EXISTS 問的問題是「這個子查詢有沒有回傳任何列？」如果 orders 裡有 customer_id = NULL 的資料，它不會「污染」我們對其他顧客的判斷。

邏輯如下（以顧客 Carol id=3 為例）：
EXISTS (SELECT 1 FROM orders WHERE customer_id = 3)

這個子查詢只找 customer_id = 3 的訂單。如果沒有，就回傳空，NOT EXISTS 就是 TRUE，Carol 就出現在結果裡。

至於 orders 表裡有沒有 customer_id = NULL 的資料，完全不影響對 customer_id = 3 的判斷。

這就是 NOT EXISTS 比 NOT IN 更安全的原因。在實際工作中，如果子查詢的欄位允許 NULL，優先使用 NOT EXISTS 或 LEFT JOIN + IS NULL。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第五部分
# 子查詢的位置

<!--
進入第五部分，說子查詢可以出現在 SQL 的哪些位置。

子查詢不只能用在 WHERE 子句，還可以出現在 SELECT 和 FROM 裡。
-->

---

# 子查詢在 WHERE 子句

這是最常見的用法，前面的範例都是這種：

```sql
-- 比較運算子 + 純量子查詢
SELECT name, amount FROM orders
WHERE amount > (
  SELECT AVG(amount) FROM orders
);

-- IN + 表子查詢
SELECT name FROM customers
WHERE id IN (
  SELECT customer_id FROM orders WHERE status = 'completed'
);

-- EXISTS + 相關子查詢
SELECT name FROM customers c
WHERE EXISTS (
  SELECT 1 FROM orders o WHERE o.customer_id = c.id
);
```

<!--
WHERE 子句裡的子查詢是最常見的形式，我們已經看了很多例子了。

三種常見模式：
1. 比較運算子 + 純量子查詢：WHERE amount > (SELECT AVG...)
2. IN/NOT IN + 表子查詢：WHERE id IN (SELECT ...)
3. EXISTS/NOT EXISTS + 相關子查詢：WHERE EXISTS (SELECT 1 ...)

這三種覆蓋了 WHERE 子查詢 90% 以上的使用場景。

大家記住：如果子查詢回傳一個值，用比較運算子；如果回傳多個值，用 IN 或 EXISTS。
-->

---

# 子查詢在 SELECT 子句

子查詢可以出現在 SELECT 後面，作為計算欄位：

```sql
-- 在每筆訂單旁邊，顯示該顧客的總訂單金額
SELECT
  o.id          AS order_id,
  o.amount      AS order_amount,
  o.status,
  (SELECT SUM(amount)
   FROM orders sub
   WHERE sub.customer_id = o.customer_id) AS customer_total
FROM orders o
ORDER BY o.customer_id, o.id;
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
⚠️ <b>效能警告：</b>SELECT 子句裡的子查詢是「相關子查詢」，對每一列都執行一次。100 筆訂單就執行 100 次子查詢，效能通常比 JOIN 差。
</div>

<!--
SELECT 子句裡的子查詢叫做「純量子查詢」，它必須剛好回傳一個值（一列一欄）。

在這個例子裡，對每一筆訂單，子查詢計算「這個顧客的所有訂單總金額」。注意 WHERE sub.customer_id = o.customer_id——這裡引用了外層查詢的 o.customer_id，這是相關子查詢。

效能問題：如果 orders 表有 10,000 筆資料，這個 SELECT 子句的子查詢就要執行 10,000 次。每次執行都要掃描 orders 表找出對應顧客的訂單，總計掃描 10,000 × （顧客平均訂單數）次。

更好的做法是用 JOIN 加 GROUP BY：
SELECT o.id, o.amount, c_total.total
FROM orders o
JOIN (SELECT customer_id, SUM(amount) AS total FROM orders GROUP BY customer_id) c_total
  ON o.customer_id = c_total.customer_id

這樣子查詢只執行一次。
-->

---

# 子查詢在 FROM 子句（衍生表）

子查詢放在 FROM 裡，把它當成一張「暫時的資料表」來查詢：

```sql
-- 找出訂單總金額前三名的顧客
SELECT customer_id, total_amount
FROM (
  SELECT customer_id, SUM(amount) AS total_amount
  FROM orders
  WHERE status = 'completed'
  GROUP BY customer_id
) AS order_summary
ORDER BY total_amount DESC
LIMIT 3;
```

FROM 後面的子查詢必須加上別名（`AS order_summary`），因為 MySQL 需要一個名稱來引用這個「暫時的資料表」。

<!--
FROM 子句裡的子查詢叫做「衍生表」（Derived Table）或「內嵌視圖」（Inline View）。

這種用法很常見：先用子查詢做一些聚合或篩選，把結果當成一張表，再對這個中間結果做進一步查詢。

在這個例子裡：
1. 子查詢先計算每個顧客的 completed 訂單總金額（GROUP BY customer_id）
2. 外層查詢從這個「order_summary」表裡取出前三名

必須給 FROM 子查詢加別名（AS order_summary），這是語法要求。

另一個常用的替代方案是 CTE（Common Table Expression，WITH 語句）：
WITH order_summary AS (
  SELECT customer_id, SUM(amount) AS total_amount ...
)
SELECT * FROM order_summary ORDER BY total_amount DESC LIMIT 3;

CTE 在可讀性上通常比 FROM 子查詢好，MySQL 8.0 完整支援 CTE。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第六部分
# 子查詢 vs JOIN

<!--
最後一個部分，說子查詢和 JOIN 的比較。

很多查詢既可以用子查詢，也可以用 JOIN 實現。選哪個更好？
-->

---

# 子查詢 vs JOIN 的比較

| 面向 | 子查詢 | JOIN |
| --- | --- | --- |
| **可讀性** | 通常更直覺（「先算這個，再用這個」）| 需要理解多表的關聯 |
| **效能** | 相關子查詢（SELECT/WHERE 裡）可能慢 | 通常更快，MySQL 最佳化器擅長 JOIN |
| **NOT IN vs LEFT JOIN** | NOT IN 有 NULL 陷阱 | LEFT JOIN + IS NULL 更安全 |
| **EXISTS 短路求值** | 找到第一個符合就停止 | 通常需要掃描所有符合的行 |
| **MySQL 最佳化** | 8.x 會嘗試將子查詢轉換為 JOIN | 直接使用 JOIN 讓最佳化器更容易 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>一般原則：</b>IN 子查詢通常可改寫成 INNER JOIN（效能相近）；NOT IN 子查詢優先改寫成 NOT EXISTS 或 LEFT JOIN + IS NULL（避免 NULL 問題）。
</div>

<!--
子查詢 vs JOIN 是一個很常見的選擇問題。

兩個主要因素：可讀性和效能。

可讀性：子查詢有時更直覺，因為它符合「先做這個，再做那個」的思考方式。JOIN 需要你同時想清楚多張表的關聯。

效能：MySQL 8.x 的查詢最佳化器很聰明，很多時候會把 IN 子查詢自動轉換成等效的 JOIN 執行。但相關子查詢（在 SELECT 或 WHERE 裡引用外層欄位的那種）通常無法被最佳化掉，效能較差。

實務建議：
1. IN + 子查詢 vs INNER JOIN：效能相近，選可讀性更好的
2. NOT IN + 子查詢 vs LEFT JOIN + IS NULL：優先用後者，避免 NULL 陷阱
3. EXISTS vs IN：資料量大時，EXISTS 可能因為短路求值而更快
4. SELECT/FROM 子查詢 vs 用 JOIN 重寫：如果是相關子查詢，盡量改用 JOIN

最終還是要用 EXPLAIN 實際測試，而不是憑感覺猜測哪個快。
-->

---

# 同一個問題的三種寫法

查詢下過 completed 訂單的顧客——三種等效寫法：

```sql
-- 寫法一：IN 子查詢
SELECT DISTINCT c.name FROM customers c
WHERE c.id IN (
  SELECT customer_id FROM orders WHERE status = 'completed'
);

-- 寫法二：EXISTS 子查詢
SELECT c.name FROM customers c
WHERE EXISTS (
  SELECT 1 FROM orders o
  WHERE o.customer_id = c.id AND o.status = 'completed'
);

-- 寫法三：INNER JOIN（通常最快，MySQL 最佳化器最擅長）
SELECT DISTINCT c.name
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id
WHERE o.status = 'completed';
```

<!--
這三個寫法的結果完全相同，讓大家直觀感受到不同寫法的差異。

寫法一（IN）：最易理解——「顧客的 ID 在 completed 訂單的 customer_id 清單裡」。
缺點：子查詢先把所有 customer_id 都取出來，形成一個清單，再逐一比對。

寫法二（EXISTS）：有短路求值優勢——「這個顧客存在 completed 訂單嗎？」找到第一筆就停止。
在顧客有很多 completed 訂單的情況下，EXISTS 會比 IN 快（不需要找完所有）。

寫法三（JOIN）：最直觀對 MySQL 最佳化器——MySQL 可以選擇最有效率的執行順序。
需要加 DISTINCT 因為一個顧客可能有多筆 completed 訂單，JOIN 後會有重複的顧客行。

⚠️ 實際選擇哪個，除了可讀性偏好，應該用 EXPLAIN 看看各個寫法的執行計畫，選效能最好的。
-->

---

# 總結

本章學了子查詢與進階查詢的核心語法：

- **子查詢** — 括號裡的 SELECT，分純量（一個值）和表（結果集）兩種
- **LIKE** — `%` 匹配任意字元，`_` 匹配一個字元；前綴搜尋效能好，中綴搜尋無法用索引
- **IN / NOT IN** — IN 搭配子查詢篩選清單；NOT IN 有 NULL 陷阱，子查詢含 NULL 時回傳空結果
- **EXISTS / NOT EXISTS** — 「存在性」判斷，相關子查詢；NOT EXISTS 不受 NULL 影響
- **子查詢位置** — WHERE（最常用）、SELECT（相關子查詢，效能差）、FROM（衍生表）
- **子查詢 vs JOIN** — IN 子查詢可改寫成 INNER JOIN；NOT IN 優先改寫成 NOT EXISTS

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
🚀 <b>進階延伸：</b>MySQL 8.x 支援 CTE（WITH 語句）讓複雜子查詢更易讀，以及 Window Functions（視窗函式）處理排名和滑動計算。
</div>

<!--
學完這章，大家能夠解決更複雜的查詢需求了。

最重要的幾個觀念：

1. NOT IN 有 NULL 陷阱——實際工作中，遇到「找不存在關聯」的需求，優先使用 NOT EXISTS 或 LEFT JOIN + IS NULL。

2. EXISTS 的短路求值——如果只需要確認「是否存在」，而不需要知道「有幾筆」，EXISTS 通常是好的選擇。

3. 相關子查詢的效能警告——SELECT 子句裡的子查詢對每一列都執行一次，資料量大時要小心。用 EXPLAIN 驗證，必要時改寫成 JOIN。

4. LIKE 的索引問題——前綴搜尋（'abc%'）可以用索引，中綴/後綴搜尋（'%abc%'）不行。

做兩道練習！
-->

---
layout: default
---

# 練習 1：任務說明
### 子查詢與 EXISTS 實作

使用本章的 customers、orders、products 資料表：

**任務：**
1. 查詢訂單金額高於**所有訂單平均金額**的訂單，顯示訂單 ID、顧客 ID、金額
2. 找出**從未取消過任何訂單**的顧客（status = 'cancelled'）
3. 查詢商品名稱中**包含「iPhone」**，且有被加入任何訂單的商品（假設有 order_items 表）

<!--
這三題難度遞增。

第一題：純量子查詢，WHERE amount > (SELECT AVG(amount) FROM orders)。

第二題：找「不存在」的記錄，可以用 NOT IN 或 NOT EXISTS。提示：選 NOT EXISTS 更安全。

第三題：結合 LIKE 和 EXISTS（或 IN），找有訂購記錄的 iPhone 商品。
-->

---
layout: default
---

# 練習 1：解題提示

```sql
-- 題一：高於平均金額的訂單
SELECT id, customer_id, amount, order_date
FROM orders
WHERE amount > (
  SELECT AVG(amount) FROM orders
)
ORDER BY amount DESC;

-- 題二：從未取消訂單的顧客（用 NOT EXISTS）
SELECT id, name, email
FROM customers c
WHERE NOT EXISTS (
  SELECT 1 FROM orders o
  WHERE o.customer_id = c.id
    AND o.status = 'cancelled'
);

-- 題三：有訂購記錄的 iPhone 商品
SELECT p.id, p.name, p.price
FROM products p
WHERE p.name LIKE '%iPhone%'
  AND EXISTS (
    SELECT 1 FROM order_items oi
    WHERE oi.product_id = p.id
  );
```

<!--
解答分析：

題一：(SELECT AVG(amount) FROM orders) 是純量子查詢，回傳一個數字。WHERE amount > 這個數字，篩選高於平均的訂單。

題二：NOT EXISTS 的相關子查詢。對每個顧客，問「這個顧客有沒有 cancelled 的訂單？」如果沒有（NOT EXISTS），就保留這個顧客。

⚠️ 如果改用 NOT IN：WHERE id NOT IN (SELECT customer_id FROM orders WHERE status = 'cancelled')，如果有 customer_id = NULL 的訂單，就會有 NULL 陷阱。NOT EXISTS 更安全。

題三：LIKE '%iPhone%' 搭配 EXISTS。對每個包含 iPhone 的商品，確認它在 order_items 表裡有記錄（被加入過訂單）。
-->

---
layout: default
---

# 練習 2：任務說明
### NOT IN 的 NULL 陷阱驗證

請用 SQL 驗證 NOT IN 的 NULL 陷阱：

```sql
-- 建立測試資料
INSERT INTO customers (name, email) VALUES
  ('Alice', 'alice@test.com'),
  ('Bob',   'bob@test.com'),
  ('Carol', 'carol@test.com');

INSERT INTO orders (customer_id, amount, status, order_date) VALUES
  (1, 500, 'completed', '2024-01-01'),
  (NULL, 300, 'completed', '2024-01-02');  -- 故意插入 NULL
```

**任務：**
1. 執行 `WHERE id NOT IN (SELECT customer_id FROM orders)` 並觀察結果
2. 改用 `NOT EXISTS` 版本，比較兩個結果的差異
3. 說明為什麼 NOT IN 版本找不到 Carol（id=3）

<!--
這題讓大家親手驗證 NULL 陷阱，比光說理論更有說服力。

NOT IN 版本：子查詢回傳 (1, NULL)，WHERE id NOT IN (1, NULL) 展開成 id != 1 AND id != NULL。id != NULL 永遠是 NULL，整個條件就是 NULL，所以沒有任何行被回傳。

NOT EXISTS 版本：對 Carol（id=3）執行子查詢，找 customer_id = 3 的訂單，沒有找到，NOT EXISTS 就是 TRUE，Carol 就出現在結果裡。

這個驗證讓大家理解為什麼「NOT EXISTS 比 NOT IN 更安全」。
-->

---
layout: default
---

# 練習 2：解題提示

```sql
-- NOT IN 版本（有 NULL 陷阱，結果為空）
SELECT id, name FROM customers
WHERE id NOT IN (
  SELECT customer_id FROM orders
);
-- 結果：空（因為子查詢含 NULL）

-- NOT EXISTS 版本（正確結果：Carol）
SELECT id, name FROM customers c
WHERE NOT EXISTS (
  SELECT 1 FROM orders o
  WHERE o.customer_id = c.id
);
-- 結果：Carol（id=3），因為她沒有訂單

-- LEFT JOIN + IS NULL 版本（同樣正確）
SELECT c.id, c.name
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
WHERE o.id IS NULL;
-- 結果：Carol（id=3）
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>結論：</b>NOT IN 子查詢回傳的清單含 NULL 時，整個 NOT IN 條件失效。生產環境建議用 NOT EXISTS 或 LEFT JOIN + IS NULL。
</div>

<!--
看這個驗證結果，NOT IN 版本回傳空，而 NOT EXISTS 和 LEFT JOIN + IS NULL 都正確找到了 Carol。

NOT IN 失敗的原因：
子查詢 SELECT customer_id FROM orders 回傳 (1, NULL)。
WHERE id NOT IN (1, NULL) 被展開為 WHERE id <> 1 AND id <> NULL。
id <> NULL 的結果是 NULL（不是 FALSE，不是 TRUE，是 NULL）。
所以整個 WHERE 條件對任何 id 都是 NULL，沒有行被回傳。

NOT EXISTS 不受影響的原因：
對 Carol（id=3）執行子查詢：SELECT 1 FROM orders WHERE customer_id = 3。
這個子查詢回傳空（orders 表裡沒有 customer_id = 3 的行），NOT EXISTS 就是 TRUE。
customer_id = NULL 的那筆訂單完全不影響對 id = 3 的判斷。

這個驗證是面試和實際工作中都很重要的知識點，請大家一定要記住！
-->

---
layout: end
---

# Q & A

有任何問題嗎？

<!--
現在開放 Q&A 時間。

大家對子查詢有沒有什麼疑問？

最重要的三個觀念：
1. NOT IN 的 NULL 陷阱——生產環境優先使用 NOT EXISTS
2. EXISTS 的短路求值——只確認存在性時使用
3. 相關子查詢的效能警告——SELECT 子句裡的子查詢要小心

如果大家想繼續深入，下一個可以學的主題是 Window Functions（視窗函式），它讓我們能夠在不改變查詢行數的情況下做聚合計算，非常強大！
-->
