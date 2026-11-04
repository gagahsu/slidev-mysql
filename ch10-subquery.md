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
大家好，歡迎來到第十章：子查詢與進階查詢。

前幾章學的 SELECT、JOIN、GROUP BY，已經能回答很多問題。可是有些問題，一個 SELECT 搞不定。例如「找出金額高於平均值的訂單」，我們得先算出平均，再拿它來篩選。

這就是子查詢要解決的事。這一章會學子查詢的各種用法，包括 IN、EXISTS，以及相關子查詢。學完之後，更複雜的業務問題也能用一個查詢解決。
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
這一章分成六段。先認識什麼是子查詢，接著深入 LIKE 的萬用字元。然後是兩種最常用的子查詢形式，IN 和 EXISTS，特別是 NOT IN 藏著的 NULL 陷阱。最後看子查詢可以放在哪些位置，以及它和 JOIN 該怎麼選。
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
這一章用的是電商訂單系統，有三張表：顧客 `customers`、訂單 `orders`、商品 `products`。

一個顧客可以有很多筆訂單，訂單用 `customer_id` 指向顧客。訂單有狀態欄位 `status`，預設是 pending，另外還有 completed 和 cancelled。商品則有分類和價格。

接下來的範例都在這三張表上示範，大家可以先記住這幾個欄位。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第一部分
# 什麼是子查詢？

<!--
我們先搞清楚子查詢是什麼，以及它適合解決什麼樣的問題。
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
「子查詢是寫在另一個 SQL 語句內部的 SELECT 語句，用括號包住，用來提供外層查詢所需的值或條件。」

先看沒有子查詢的做法，要分兩步。第一步查出平均金額，假設是一千五。第二步再把一千五手動填進另一個查詢。這不只麻煩，資料一更新，手動填的數字就過時了。

有了子查詢，只要一步。把算平均的 SELECT 用括號包起來，直接放進 WHERE。MySQL 會先執行括號裡的子查詢，得到平均值，再拿這個值來篩選外層的訂單。

執行後，會列出所有高於平均金額的訂單，而且平均值永遠是根據當下的資料計算的。
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
子查詢依照回傳的資料形式，分成三種。

純量子查詢只回傳一個值，例如平均金額，可以直接用等於、大於這些比較運算子。列子查詢回傳一列多欄，比較少用。表子查詢回傳多列的結果集，例如所有下過訂單的顧客編號。

結果集不能直接拿來比大小，要用 IN 判斷「在不在這個集合裡」，或用 EXISTS 判斷「這個集合是不是空的」。

所以最常用的組合是兩種：純量子查詢搭配比較運算子，表子查詢搭配 IN 或 EXISTS。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第二部分
# LIKE 進階用法

<!--
接下來深入 LIKE。第五章已經學過基礎，這裡補上萬用字元的細節和效能陷阱。
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
「LIKE 是模糊比對運算子，百分比代表任意長度的任意字元，底線代表恰好一個任意字元。」

表格列出了常見的模式。`'iPhone%'` 是以 iPhone 開頭，`'%手機%'` 是包含手機，`'%Pro'` 是以 Pro 結尾。底線比較嚴格，`'___'` 三個底線，就是剛好三個字元。

這裡最重要的是效能。以百分比開頭的模式用不到 B-Tree 索引。索引是依字首排序的，開頭不確定，MySQL 就不知道從哪裡找，只能全表掃描。

如果應用需要大量的包含搜尋，可以考慮 FULLTEXT 索引，或是 Elasticsearch 這類搜尋引擎。
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
這頁有四種常見的 LIKE 寫法。

第一個是前綴搜尋，用得到索引，效能最好。第二個是包含搜尋，資料少時還可以接受，資料到了幾百萬筆就會很慢。

第三個是 `NOT LIKE`，排除名稱裡有二手的商品，再搭配分類是手機的條件，執行後會得到所有非二手的手機。

第四個是 `ESCAPE`。如果要搜尋的文字本身就有百分比符號，例如五十趴 off，就要用 ESCAPE 指定跳脫字元，讓 LIKE 把百分比當成普通字元。

另外提醒，在不分大小寫的排序規則下，LIKE 也不分大小寫。需要區分的話，可以用 `LIKE BINARY`。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第三部分
# IN / NOT IN 與子查詢

<!--
接下來是 IN 和 NOT IN。我們先複習基本用法，再看搭配子查詢的寫法。
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
「IN 判斷一個欄位的值是否在指定的清單中。」

第一段篩選分類是手機、平板或電腦的商品，效果等同於三個 OR，但簡潔多了。第二段的 `NOT IN` 反過來，排除配件和二手。選項一多，IN 比一串 OR 好讀很多。

這裡要先埋一個伏筆。如果 NOT IN 的清單裡出現 NULL，結果會出乎意料。因為跟 NULL 比較的結果既不是真也不是假，整個條件就成立不了，查詢一筆資料都不會回傳。

這個陷阱，等一下搭配子查詢時會看得更清楚。
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
「IN 的清單不只可以是靜態值，也可以是子查詢的結果。」

這段查詢要找出下過完成訂單的顧客。執行順序是這樣的。MySQL 先執行括號裡的子查詢，從訂單表取出所有完成訂單的 `customer_id`，得到一份清單，例如一、三、五號。接著外層查詢再從顧客表裡，挑出 id 在這份清單裡的顧客。

執行後，就得到所有下過完成訂單的顧客名單。

這個查詢也能用 INNER JOIN 寫，效果一樣，不過 JOIN 要多加 DISTINCT 去除重複。兩種寫法的效能比較，我們在最後一段會談。
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
「NOT IN 搭配子查詢，找出在某表中沒有對應記錄的資料。」這段查詢要找出從來沒下過訂單的顧客。

寫法很直覺，可是有一個嚴重的 NULL 陷阱。如果訂單表裡有一筆 `customer_id` 是 NULL，子查詢就會回傳像一、三、五、NULL 這樣的清單。

NOT IN 會展開成 id 不等於一，而且不等於三，而且不等於五，而且不等於 NULL。最後那個比較永遠得不到真，整個條件就不成立，查詢一筆都回傳不了。

這個問題很隱蔽，平常沒有 NULL 時一切正常，哪天出現一筆，結果就突然錯了。

安全的做法有三種：確保欄位設了 `NOT NULL`，或改用 NOT EXISTS，或用 LEFT JOIN 加 IS NULL。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第四部分
# EXISTS / NOT EXISTS

<!--
接下來是 EXISTS。它和 IN 一樣重要，但判斷的邏輯完全不同。
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
「EXISTS 不關心子查詢回傳什麼資料，只關心子查詢是否回傳了至少一列。」

畫面上同一個問題寫了兩次。IN 版本是先取出清單，再一一對照。EXISTS 版本則是對每一位顧客問一次：這個顧客有完成的訂單嗎？只要找到一筆，答案就是有，這位顧客就被留下。

注意 EXISTS 子查詢裡的 `o.customer_id = c.id`，它引用了外層的顧客 id。這種子查詢用到外層欄位的寫法，叫做「相關子查詢」。

子查詢裡寫 `SELECT 1`，是因為 EXISTS 只在乎有沒有結果，選什麼欄位都不重要。

EXISTS 還有一個好處，找到第一筆符合的資料就會停下來，不用把全部找完。
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
「NOT EXISTS 當子查詢回傳空結果時為 TRUE，用來找出沒有對應記錄的資料。」

這段查詢同樣是找從來沒下過訂單的顧客，但不會有 NULL 陷阱。為什麼呢？以 Carol 為例，子查詢只會去找 `customer_id` 等於 Carol 編號的訂單。找不到，NOT EXISTS 就成立，Carol 就會出現在結果裡。訂單表裡有沒有 NULL 的資料，完全不影響對 Carol 的判斷。

下方表格整理了兩者的差別。NOT IN 只適合在子查詢欄位確定沒有 NULL 時使用。欄位可能有 NULL，就優先用 NOT EXISTS。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第五部分
# 子查詢的位置

<!--
子查詢不只能放在 WHERE。接下來看它還能出現在 SELECT 和 FROM 裡。
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
WHERE 裡的子查詢是最常見的，這頁整理了三種模式。

第一種是比較運算子搭配純量子查詢，例如金額大於平均值。第二種是 IN 搭配表子查詢，例如顧客 id 在完成訂單的清單裡。第三種是 EXISTS 搭配相關子查詢，例如這個顧客有沒有訂單。

這三種涵蓋了 WHERE 子查詢絕大部分的使用場景。

選擇的方法很簡單：子查詢回傳一個值，就用比較運算子；回傳多個值，就用 IN 或 EXISTS。
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
子查詢也可以放在 SELECT 後面，當成一個計算出來的欄位。

這段查詢在每一筆訂單旁邊，多顯示這位顧客所有訂單的總金額。關鍵是 `sub.customer_id = o.customer_id`，它引用了外層這筆訂單的顧客，所以這也是相關子查詢。這裡的子查詢必須剛好回傳一個值。

執行後，每筆訂單都會多一欄 `customer_total`。

不過效能要小心。外層有一萬筆訂單，這個子查詢就要執行一萬次。

比較好的做法，是先用一個子查詢依顧客分組算出總金額，再 JOIN 回訂單表。這樣分組統計只要做一次。
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
子查詢放在 FROM 裡，就是把它的結果當成一張暫時的資料表，這叫做衍生表。

這段查詢要找出完成訂單總金額最高的前三位顧客。裡面的子查詢先依顧客分組，算出每個人的總金額。外層再把這個結果當成一張表，依金額排序，取前三筆。

要注意，FROM 裡的子查詢一定要取別名，例如這裡的 `AS order_summary`，否則 MySQL 會報錯。

另一個常見的寫法是 CTE，也就是 WITH 語句。先用 WITH 幫中間結果取名字，再在後面查詢它。可讀性通常比較好，MySQL 8 已經完整支援。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第六部分
# 子查詢 vs JOIN

<!--
最後一段，很多查詢既能用子查詢寫，也能用 JOIN 寫，到底該怎麼選？
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
表格從幾個面向比較子查詢和 JOIN。

可讀性上，子查詢通常比較直覺，符合「先算這個，再用這個」的思考方式。效能上，MySQL 8 的最佳化器很聰明，常會把 IN 子查詢自動轉成 JOIN 執行。但相關子查詢要對每一列都執行一次，通常比較慢。

所以實務建議是這樣的。IN 子查詢和 INNER JOIN 效能相近，選好讀的就好。NOT IN 優先改寫成 NOT EXISTS 或 LEFT JOIN 加 IS NULL，避開 NULL 陷阱。SELECT 裡的相關子查詢，盡量改用 JOIN。

最後，不要憑感覺猜哪個快，用前面索引那一章學的 EXPLAIN 實際看看。
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
這頁把同一個問題，用三種寫法寫出來：找出下過完成訂單的顧客。

寫法一是 IN，最好理解，顧客的 id 在完成訂單的清單裡。寫法二是 EXISTS，對每位顧客問有沒有完成的訂單，找到一筆就停，顧客訂單很多時可能比較快。寫法三是 INNER JOIN，最佳化器最擅長處理，但因為一位顧客可能有好幾筆完成訂單，JOIN 之後會重複，所以要加 DISTINCT。

這三種寫法執行後的結果完全一樣。實際要選哪個，除了可讀性，最好用 EXPLAIN 比較執行計畫。
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
我們整理這一章。子查詢是括號裡的 SELECT，最常用的是回傳一個值的純量子查詢，和回傳結果集的表子查詢。LIKE 的前綴搜尋用得到索引，包含搜尋用不到。

IN 搭配子查詢篩選清單，但 NOT IN 遇到 NULL 會整個失效。EXISTS 判斷存在性，NOT EXISTS 不受 NULL 影響。子查詢可以放在 WHERE、SELECT 和 FROM，其中 SELECT 裡的相關子查詢要注意效能。

接下來，我們用兩題練習把這些觀念練熟。
-->

---
layout: default
---

# 練習 1：任務說明
### 動態問卷：用子查詢與 EXISTS 找答案

使用 `dynamic_survey` 資料庫（`sql/schema.sql` + `sql/seed.sql`）：

**任務：**
1. 找出作答人數**高於平均**的問卷，顯示 ID、標題、作答人數（平均只算有人作答的問卷）
2. 「待填寫」清單：找出**進行中**、而且 `ming@example.com` **還沒填過**的問卷（NOT EXISTS）
3. 找出**有人填寫過**，而且**包含必填題目**的問卷（EXISTS）

<!--
這一題有三個問卷系統的真實需求，難度一題比一題高。

第一題要比較作答人數和平均，可是平均要先算出每份問卷的人數才能計算。第二題要找不存在的紀錄。第三題有兩個條件，各自對應一個 EXISTS。

思考一下，平均人數可以直接寫成 `AVG(COUNT(*))` 嗎？

我們先暫停一下，自己動手寫寫看。

【講師】給大家十五分鐘，第一題可以提示先寫出每份問卷的人數。
-->

---
layout: default
---

# 練習 1：解題提示

```sql
-- 1. 作答人數高於平均的問卷
SELECT s.id, s.title,
       (SELECT COUNT(*) FROM survey_responses r
        WHERE r.survey_id = s.id) AS response_count
FROM surveys s
WHERE (SELECT COUNT(*) FROM survey_responses r
       WHERE r.survey_id = s.id) > (
        SELECT AVG(cnt)
        FROM (SELECT COUNT(*) AS cnt
              FROM survey_responses
              GROUP BY survey_id) t
      )
ORDER BY response_count DESC;
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>結果：</b>平均是 2.5 人，所以是午餐偏好調查（4 人）和校園活動調查（3 人）。
</div>

<!--
先回答思考題，`AVG(COUNT(*))` 是不行的，聚合函式不能這樣巢狀使用。

所以我們用衍生表，先算出每份問卷的人數，再取平均，得到二點五。外層再拿每份問卷的人數和它比較。

每份問卷的人數，用相關子查詢算出來，因為它要參照外層的 `s.id`。

執行後會查到兩份問卷，午餐偏好調查四人，校園活動調查三人。
-->

---
layout: default
---

# 練習 1：解題提示（續）

```sql
-- 2. 進行中，且 ming 還沒填過的問卷
SELECT s.id, s.title, s.end_date
FROM surveys s
WHERE s.published = 1
  AND CURDATE() BETWEEN s.start_date AND s.end_date
  AND NOT EXISTS (
    SELECT 1 FROM survey_responses r
    WHERE r.survey_id = s.id
      AND r.email = 'ming@example.com'
  );

-- 3. 有人填寫過，且包含必填題目的問卷
SELECT s.id, s.title
FROM surveys s
WHERE EXISTS (SELECT 1 FROM survey_responses r
              WHERE r.survey_id = s.id)
  AND EXISTS (SELECT 1 FROM questions q
              WHERE q.survey_id = s.id AND q.required = 1);
```

<!--
第二題，對每份進行中的問卷問一次，ming 有沒有填過？沒有的話就留下來。進行中的是問卷 2、3、6，ming 填過 2 和 6，所以只剩下新品口味調查。

第三題，兩個 EXISTS 用 AND 連接，各自判斷有沒有作答、有沒有必填題。結果是問卷 1、2、3、6。

EXISTS 只要找到一筆就會停止，所以很適合只想確認存不存在的情境。
-->

---
layout: default
---

# 練習 2：任務說明
### NOT IN 的 NULL 陷阱：真實的問卷資料

問卷允許**訪客免登入**作答，所以 `survey_responses.user_id` 裡有 `NULL`。這正好會踩到 `NOT IN` 的陷阱，請親手驗證：

**任務：**
1. 找出**從未填寫過問卷的會員**，先用 `WHERE id NOT IN (SELECT user_id FROM survey_responses)` 寫寫看
2. 改用 `NOT EXISTS` 與 `LEFT JOIN ... IS NULL` 版本，比較結果
3. 說明為什麼 `NOT IN` 版本找不到「管理員」（`id = 1`）
4. 如果一定要用 `NOT IN`，該怎麼修正？

<!--
剛才我們學過 NOT IN 的 NULL 陷阱，這題就在問卷資料上親手驗證。不用另外造假資料，因為範例資料裡本來就有訪客作答，`user_id` 是 NULL。

請大家用三種寫法找出沒填過問卷的會員，比較結果有什麼不同。

思考一下，`NOT IN` 的清單裡有 NULL 時，條件會展開成什麼樣子？

我們先暫停一下，自己動手試試看。

【講師】給大家十分鐘，可以請同學先預測三種寫法的結果。
-->

---
layout: default
---

# 練習 2：解題提示

```sql
-- NOT IN 版本（有 NULL 陷阱，結果為空）
SELECT id, name FROM users
WHERE id NOT IN (SELECT user_id FROM survey_responses);

-- NOT EXISTS 版本（正確：管理員）
SELECT id, name FROM users u
WHERE NOT EXISTS (SELECT 1 FROM survey_responses r
                  WHERE r.user_id = u.id);

-- LEFT JOIN + IS NULL 版本（正確：管理員）
SELECT u.id, u.name
FROM users u
LEFT JOIN survey_responses r ON r.user_id = u.id
WHERE r.id IS NULL;

-- 修正 NOT IN：子查詢排除 NULL
SELECT id, name FROM users
WHERE id NOT IN (SELECT user_id FROM survey_responses
                 WHERE user_id IS NOT NULL);
```

<!--
第一個版本查不到任何資料，後面三個版本都正確找到管理員。

原因是 NOT IN 會展開成一連串的不等於，其中包含不等於 NULL。和 NULL 比較的結果既不是真也不是假，整個條件就不會成立，所以一筆都查不到。

NOT EXISTS 不受影響，因為它只看有沒有符合的紀錄。

修正的方法是在子查詢排除 NULL，但這要靠寫的人記得，所以還是優先用 NOT EXISTS。
-->

---
layout: end
---

# Q & A

有任何問題嗎？

<!--
今天我們學了子查詢的各種用法。最重要的三個觀念是：NOT IN 有 NULL 陷阱，找不存在的資料時優先用 NOT EXISTS；EXISTS 找到一筆就停，適合確認是否存在；SELECT 裡的相關子查詢會逐列執行，要注意效能。

到這裡，我們從資料庫設計、建表、增刪改查，一路學到 JOIN、索引、VIEW 和子查詢，MySQL 的基礎已經完整了。接下來，就把這些技巧用在自己的專案裡吧。

【講師】開放提問，可以請同學比較同一題用 IN、EXISTS、JOIN 三種寫法的差別。
-->
