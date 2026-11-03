---
theme: penguin
class: text-center
highlighter: shiki
lineNumbers: true
drawings:
  persist: false
transition: slide-left
title: JOIN 合併查詢
routeAlias: ch07
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
    JOIN 合併查詢
  </h1>
  <div style="height: 4px; width: 320px; background: linear-gradient(90deg, #5eada0, #a7d9d0); border-radius: 2px; margin-bottom: 1.5rem;"></div>
  <p style="color: #4a7c7c; font-size: 1.15rem; font-style: italic;">
    「把分散在不同表的資料，合在一起看」
  </p>
  <Link to="home" style="color: #9dc4c4; font-size: 0.85rem; margin-top: 2rem; text-decoration: none; letter-spacing: 0.05em;">← 返回目錄</Link>
</div>

<!--
大家好，歡迎來到第七章：JOIN 合併查詢。

前幾章我們把顧客、訂單、商品拆進不同的表。可是想看「誰買了什麼」，資料卻分散在好幾張表裡。

這就是 JOIN 要解決的事。「JOIN 的作用，就是把兩張或多張有關聯的資料表，根據共同欄位合併成一張結果。」學完這章，大家就能用一個查詢，把分散的資料合在一起看。
-->

---
layout: default
---

# Outline

- **什麼是 JOIN？** — JOIN 的概念與使用場景
- **INNER JOIN** — 只回傳兩表都有的資料
- **LEFT JOIN** — 保留左表所有資料
- **RIGHT JOIN** — 保留右表所有資料
- **CROSS JOIN** — 笛卡兒積，所有組合
- **Self JOIN** — 自身和自身合併

<!--
這一章會介紹五種 JOIN。先學最常用的 INNER JOIN 和 LEFT JOIN，這兩個學會了，其他的都很好理解。接著看 RIGHT JOIN，最後是比較特殊的 CROSS JOIN 和 Self JOIN。

整章都會用同一組顧客和訂單資料，讓大家清楚看到每種 JOIN 的差別。
-->

---

# 範例資料表

本章使用顧客與訂單系統作為範例：

```sql
CREATE TABLE customers (
  id   INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE orders (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT,
  amount      DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

| customers | | orders | |
| --- | --- | --- | --- |
| id=1, Alice | | id=1, customer_id=1, $500 | |
| id=2, Bob | | id=2, customer_id=1, $300 | |
| id=3, Carol（無訂單）| | id=3, customer_id=NULL（未知顧客）| |

<!--
這是整章範例的資料基礎，有兩張表：顧客表 `customers` 和訂單表 `orders`，訂單用 `customer_id` 指向顧客。

顧客有三位：Alice、Bob、Carol。訂單有三筆，前兩筆都是 Alice 的，第三筆的 `customer_id` 是 NULL，代表不知道是誰下的。

這組資料是刻意設計的，有兩個特別的地方要記住。第一，有顧客沒有任何訂單。第二，有一筆訂單找不到對應的顧客。

接下來每一種 JOIN，差別就在於怎麼處理這兩種「對不上」的資料。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第一部分
# INNER JOIN

<!--
我們從最常用的 INNER JOIN 開始。先說結論：它只保留兩張表都對得上的資料。
-->

---

# 什麼是 INNER JOIN？

「INNER JOIN 只回傳在兩張表中都能找到對應資料的列。如果某一邊沒有對應，就不出現在結果裡。」

用集合圖來理解：

- 左圓 = customers 表
- 右圓 = orders 表
- **INNER JOIN = 只取交集的部分**

| 結果 | 說明 |
| --- | --- |
| Alice 的訂單 ✅ | customers.id = orders.customer_id = 1 |
| Bob 的訂單 ❌ | Bob 沒有訂單，不出現在結果 |
| Carol ❌ | Carol 沒有訂單，不出現在結果 |
| customer_id=NULL 訂單 ❌ | 找不到對應顧客，不出現在結果 |

<!--
「INNER JOIN 只回傳在兩張表中都能找到對應資料的列。如果某一邊沒有對應，就不出現在結果裡。」

我們可以想像兩個圓，左邊是顧客，右邊是訂單。INNER JOIN 只取兩個圓重疊的那一塊，也就是交集。

套進我們的資料，只有 Alice 兩邊都有，顧客表有她，訂單表也有她的訂單，所以只有 Alice 會出現。

表格裡也標出了其他人。Bob 和 Carol 在顧客表裡，但沒有訂單，所以不會出現。那筆 `customer_id` 是 NULL 的訂單，找不到對應的顧客，也不會出現。

記住一句話就好：「兩邊都有才保留。」
-->

---

# INNER JOIN 的語法結構

```sql
SELECT column_list
FROM table1
INNER JOIN table2 ON table1.column = table2.column
[WHERE ...]
[ORDER BY ...];
```

查詢每筆訂單對應的顧客姓名：

```sql
SELECT
  c.name       AS customer_name,
  o.id         AS order_id,
  o.amount     AS order_amount
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id
ORDER BY c.name, o.id;
```

執行後，你會看到 Alice 的兩筆訂單（$500 和 $300）。Bob 和 Carol 不在結果中，customer_id=NULL 的訂單也不在。

<!--
上面是 INNER JOIN 的語法結構，`FROM` 接第一張表，`INNER JOIN` 接第二張表，`ON` 後面寫兩張表怎麼對應。

下面的範例要查出每筆訂單和下單顧客的姓名。

第一個重點是別名。`FROM customers c` 讓 c 代表顧客表，o 代表訂單表，SQL 會簡潔很多。

第二個重點是 `ON c.id = o.customer_id`，意思是顧客的 id 要等於訂單裡的 customer_id，兩筆資料才算對上。

另外，SELECT 的欄位前面都加了表的別名。兩張表都有 `id` 欄位，不加的話，MySQL 不知道我們要哪一張的。

執行後，會看到 Alice 的兩筆訂單，五百元和三百元。Bob、Carol 和那筆不明訂單都不會出現。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第二部分
# LEFT JOIN

<!--
接下來是 LEFT JOIN，實務上用得非常多，特別是需要保留某張表所有資料的時候。
-->

---

# 什麼是 LEFT JOIN？

「LEFT JOIN 保留左表（FROM 後面那張）的所有列，右表沒有對應的地方填入 NULL。」

用集合圖來理解：

- **LEFT JOIN = 左圓全部 + 交集**（右邊沒有的補 NULL）

| 結果 | 說明 |
| --- | --- |
| Alice 的訂單 ✅ | 正常對應 |
| Bob — NULL, NULL ✅ | Bob 在左表，右表沒有訂單，amount 填 NULL |
| Carol — NULL, NULL ✅ | Carol 在左表，右表沒有訂單，amount 填 NULL |
| customer_id=NULL 訂單 ❌ | 這筆在右表，LEFT JOIN 不從右表多取 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>最常見的用途：</b>找出「沒有 XXX 的 YYY」，例如「找出從未下過訂單的顧客」。
</div>

<!--
「LEFT JOIN 保留左表的所有列，右表沒有對應的地方填入 NULL。」左表指的是寫在 FROM 後面的那一張。

用兩個圓來看，LEFT JOIN 是整個左圓，包含交集的部分。

套進資料，以顧客為左表。Alice 有訂單，正常顯示。Bob 和 Carol 沒有訂單，但他們還是會出現在結果裡，只是訂單編號和金額都是 NULL。至於那筆不明訂單，它在右表，LEFT JOIN 不會多取，所以不會出現。

它最常見的用途，就是找出「沒有某樣東西」的資料，例如從來沒下過訂單的顧客。下一頁我們來看怎麼寫。
-->

---

# LEFT JOIN 的語法與範例

```sql
-- 查詢所有顧客（含沒有訂單的），顯示訂單金額
SELECT
  c.name       AS customer_name,
  o.id         AS order_id,
  o.amount     AS order_amount
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
ORDER BY c.name;
```

找出從未下訂單的顧客：

```sql
SELECT c.name AS customer_name
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
WHERE o.id IS NULL;
```

執行後，你會看到 Bob 和 Carol——他們在 customers 表裡，但 orders 表裡沒有他們的訂單。

<!--
這頁有兩個 LEFT JOIN 最常用的寫法。

第一段是完整的 LEFT JOIN。執行後，三位顧客都會出現，Alice 有兩筆訂單金額，Bob 和 Carol 的訂單欄位則是 NULL。

第二段是一個非常實用的技巧，LEFT JOIN 再加上 `WHERE o.id IS NULL`。原理是這樣的，LEFT JOIN 之後，沒有訂單的顧客，訂單欄位都是 NULL。我們只要把這些列留下來，剩下的就是沒有下過訂單的顧客。執行後會得到 Bob 和 Carol。

這個寫法的應用很廣，像是找出沒有上傳大頭貼的使用者、從來沒被借過的書。

要注意，IS NULL 要判斷的是右表的欄位，判斷左表的欄位就找不到了。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第三部分
# RIGHT JOIN

<!--
接下來是 RIGHT JOIN。它其實就是 LEFT JOIN 的鏡像，改成保留右表的全部資料。
-->

---

# RIGHT JOIN — 保留右表所有資料

「RIGHT JOIN 保留右表（JOIN 後面那張）的所有列，左表沒有對應的地方填入 NULL。」

```sql
-- 查詢所有訂單（含顧客不明的），顯示顧客姓名
SELECT
  c.name       AS customer_name,
  o.id         AS order_id,
  o.amount     AS order_amount
FROM customers c
RIGHT JOIN orders o ON c.id = o.customer_id
ORDER BY o.id;
```

| 結果 | 說明 |
| --- | --- |
| Alice — 訂單 #1, $500 ✅ | 正常對應 |
| Alice — 訂單 #2, $300 ✅ | 正常對應 |
| NULL — 訂單 #3, $100 ✅ | 右表有訂單，但左表沒有對應顧客，name 填 NULL |
| Bob, Carol ❌ | 他們在左表，RIGHT JOIN 不從左表多取 |

<!--
「RIGHT JOIN 保留右表的所有列，左表沒有對應的地方填入 NULL。」右表指的是寫在 JOIN 後面的那一張。

這段查詢以訂單為右表，所以所有訂單都會保留。執行後，Alice 的兩筆訂單正常顯示。第三筆訂單也會出現，但因為找不到顧客，顧客姓名是 NULL。Bob 和 Carol 在左表，沒有訂單，就不會出現。

實務上，RIGHT JOIN 比較少人用。只要把兩張表的位置交換，寫成 `FROM orders` 再 LEFT JOIN 顧客表，結果就完全一樣。

大多數工程師習慣用 LEFT JOIN，因為從左往右讀比較直覺，整個專案統一用一種寫法，也比較好維護。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第四部分
# CROSS JOIN 與 Self JOIN

<!--
最後兩種是 CROSS JOIN 和 Self JOIN。它們比較少見，但在特定場景很好用。
-->

---

# CROSS JOIN — 笛卡兒積

「CROSS JOIN 把左表的每一列和右表的每一列都配對一次，產生所有可能的組合。」

```sql
-- 3 個顏色 × 3 種尺寸 = 9 種商品規格組合
SELECT
  c.color_name,
  s.size_name
FROM colors c
CROSS JOIN sizes s;
```

| 使用場景 | 說明 |
| --- | --- |
| 生成所有規格組合 | 顏色 × 尺寸 = 所有商品 SKU |
| 日期序列生成 | 所有日期 × 所有員工 |
| 測試資料生成 | 快速生成大量排列組合 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
⚠️ <b>注意：</b>CROSS JOIN 沒有 ON 條件。如果兩張表都很大，結果會是天文數字（m × n 筆），要謹慎使用。
</div>

<!--
「CROSS JOIN 把左表的每一列和右表的每一列都配對一次，產生所有可能的組合。」這在數學上叫做笛卡兒積。

最直觀的例子是服裝的規格。三種顏色、三種尺寸，所有的組合就是三乘三，九種。這段查詢用 CROSS JOIN 把顏色表和尺寸表配對，執行後就會一次列出九種規格，不用手動一個一個列。

要注意的是，CROSS JOIN 沒有 ON 條件。兩張表如果各有一萬筆，結果就是一億筆。

還有一個很常見的坑。寫一般 JOIN 時如果漏了 ON 條件，結果也會變成類似 CROSS JOIN 的全部配對。所以只要發現查詢結果的筆數比預期多很多，第一個就要檢查是不是漏了 ON。
-->

---

# Self JOIN — 自身和自身合併

「Self JOIN 是把一張表和它自己進行 JOIN，用來查詢表內的階層關係或比較關係。」

查詢員工和他們的主管（都存在同一張 employees 表）：

```sql
SELECT
  e.name          AS employee_name,
  m.name          AS manager_name
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id
ORDER BY m.name, e.name;
```

LEFT JOIN 確保沒有主管的員工（最高層主管）也會出現在結果中，manager_name 為 NULL。

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>必要條件：</b>Self JOIN 必須使用別名，讓兩個「版本」的同一張表有不同的名字（e 和 m），否則 SQL 無法區分。
</div>

<!--
「Self JOIN 是把一張表和它自己進行 JOIN，用來查詢表內的階層關係或比較關係。」

最常見的例子是員工和主管。每個員工都有一個 `manager_id`，指向同一張表裡另一個員工。要查出每個人的主管姓名，就得讓員工表跟自己 JOIN。

關鍵在別名。同一張 `employees`，我們叫它 e 的時候代表員工，叫它 m 的時候代表主管。`ON e.manager_id = m.id` 的意思是，員工的主管編號，等於主管的 id。沒有別名的話，MySQL 就分不出這兩個身分。

這裡用的是 LEFT JOIN。最高層的主管沒有上司，INNER JOIN 會把他排除掉。用 LEFT JOIN，執行後他也會出現，主管欄位顯示 NULL。
-->

---

# JOIN 類型總結

| JOIN 類型 | 結果 | 使用時機 |
| --- | --- | --- |
| `INNER JOIN` | 兩表都有對應才保留 | 只需要有關聯的資料 |
| `LEFT JOIN` | 左表全保留，右表補 NULL | 保留左表所有資料，右表可能沒有 |
| `RIGHT JOIN` | 右表全保留，左表補 NULL | 保留右表所有資料（較少用）|
| `CROSS JOIN` | 所有組合（m × n 筆）| 生成規格組合等笛卡兒積場景 |
| `Self JOIN` | 表和自己 JOIN | 樹狀/階層關係查詢 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>最常用的組合：</b>90% 的場景用 INNER JOIN 或 LEFT JOIN 就夠了。其他 JOIN 類型只在特定需求下使用。
</div>

<!--
這張表把五種 JOIN 整理在一起。

實務上，九成的情況用 INNER JOIN 或 LEFT JOIN 就夠了。只需要有關聯的資料，例如訂單和下單顧客，就用 INNER JOIN。需要保留某一邊的全部資料，另一邊可能沒有對應，例如列出所有顧客，包含沒下過單的，就用 LEFT JOIN。

可以記住一個原則：「從哪張表出發，就把那張表放在 LEFT JOIN 的左邊。」
-->

---

# 總結

本章學了 JOIN 合併查詢的五種類型：

- **INNER JOIN** — 取兩表的交集，兩邊都有才出現
- **LEFT JOIN** — 保留左表所有資料，右表沒有的補 NULL；可搭配 `IS NULL` 找「不存在關聯」的記錄
- **RIGHT JOIN** — 保留右表所有資料（可改寫為 LEFT JOIN）
- **CROSS JOIN** — 笛卡兒積，生成所有組合，無 ON 條件
- **Self JOIN** — 表和自身 JOIN，用於階層關係；必須使用別名

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
🚀 <b>下一章：</b>我們將學習 Index 索引和 EXPLAIN 執行計畫，了解如何讓查詢跑得更快！
</div>

<!--
我們整理一下這一章。INNER JOIN 取交集，兩邊都有才出現。LEFT JOIN 保留左表全部，右表沒有的補 NULL，搭配 IS NULL 就能找出沒有關聯的資料。RIGHT JOIN 可以改寫成 LEFT JOIN。CROSS JOIN 產生所有組合，沒有 ON 條件。Self JOIN 讓表和自己合併，一定要用別名。

接下來，我們用兩題練習把這些寫法練熟。
-->

---
layout: default
---

# 練習 1：任務說明
### 查詢訂單與顧客資訊

使用以下資料表：

```sql
-- customers (id, name, email)
-- orders (id, customer_id, amount, status, order_date)
-- products (id, name, price, category)
-- order_items (order_id, product_id, quantity)
```

**任務：**
1. 查詢所有 `completed` 狀態訂單，顯示顧客姓名、訂單金額（用 INNER JOIN）
2. 查詢**從未下過訂單**的顧客名單（用 LEFT JOIN + IS NULL）
3. 查詢每筆訂單包含的商品名稱（需要 JOIN 三張表）

<!--
第一題，我們有顧客、訂單、商品和訂單明細四張表。

任務有三個，難度逐漸增加。第一個是查出所有完成狀態的訂單，顯示顧客姓名和金額。第二個是找出從來沒下過訂單的顧客。第三個是查出每筆訂單包含了哪些商品，這需要串起三張表。

想想看，訂單和商品之間沒有直接的欄位相連，那要經過哪一張表才能把它們接起來？

我們先暫停一下，自己寫寫看。

【講師】給大家十分鐘，可以提示多個 JOIN 子句可以連續寫下去。
-->

---
layout: default
---

# 練習 1：解題提示

```sql
-- 題一：completed 訂單 + 顧客名稱
SELECT c.name, o.amount, o.order_date
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id
WHERE o.status = 'completed'
ORDER BY o.order_date DESC;

-- 題二：從未下訂的顧客
SELECT c.name, c.email
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
WHERE o.id IS NULL;

-- 題三：訂單包含的商品（三表 JOIN）
SELECT o.id AS order_id, p.name AS product_name,
       oi.quantity, p.price
FROM orders o
INNER JOIN order_items oi ON o.id = oi.order_id
INNER JOIN products p    ON oi.product_id = p.id
ORDER BY o.id, p.name;
```

<!--
我們來看解答。

第一題是基本的 INNER JOIN，用顧客 id 對上訂單的 customer_id，再用 WHERE 篩選狀態是 completed 的訂單，執行後依日期由新到舊列出。

第二題就是剛才學的技巧，LEFT JOIN 保留所有顧客，再用 `WHERE o.id IS NULL` 留下沒有訂單的人。

第三題回答了剛才的問題。訂單和商品要透過訂單明細 `order_items` 接起來。先用 `order_id` 把訂單接到明細，再用 `product_id` 把明細接到商品，兩個 INNER JOIN 連續寫下去就可以了。

多表 JOIN 時，每個欄位前面都要加上表的別名。
-->

---
layout: default
---

# 練習 2：任務說明
### 分析員工組織架構

有一張員工表，包含員工和其直屬主管的關係：

```sql
CREATE TABLE employees (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(100) NOT NULL,
  manager_id INT,
  department VARCHAR(100),
  salary     DECIMAL(10,2),
  FOREIGN KEY (manager_id) REFERENCES employees(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**任務：**
1. 查詢每個員工的姓名和其主管的姓名（沒有主管的顯示 NULL）
2. 找出薪資高於其直屬主管的員工

<!--
第二題要分析員工的組織架構。這張員工表裡，`manager_id` 指向同一張表裡的另一個員工，也就是直屬主管。

任務有兩個。第一個是列出每個員工和他主管的姓名，沒有主管的人也要出現。第二個是找出薪水比自己直屬主管還高的員工。

這兩題都需要 Self JOIN。想想看，第一題和第二題，應該分別用 LEFT JOIN 還是 INNER JOIN？

我們先暫停一下，動手試試看。

【講師】給大家十分鐘，可以提醒先決定好兩個別名各代表什麼身分。
-->

---
layout: default
---

# 練習 2：解題提示

```sql
-- 題一：員工和主管姓名
SELECT
  e.name          AS employee_name,
  e.department,
  m.name          AS manager_name
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id
ORDER BY m.name NULLS LAST, e.name;

-- 題二：薪資高於主管的員工
SELECT
  e.name          AS employee_name,
  e.salary        AS employee_salary,
  m.name          AS manager_name,
  m.salary        AS manager_salary
FROM employees e
INNER JOIN employees m ON e.manager_id = m.id
WHERE e.salary > m.salary
ORDER BY e.salary DESC;
```

<!--
我們來看解答。兩題都用 e 代表員工、m 代表主管，`ON e.manager_id = m.id` 把員工接到他的主管。

第一題用 LEFT JOIN。最高層的主管沒有上司，用 LEFT JOIN 他才會出現在結果裡，主管欄位顯示 NULL。

第二題用 INNER JOIN，因為我們只關心有主管可以比較的員工。接著用 `WHERE e.salary > m.salary`，比較同一張表裡兩筆資料的薪水。執行後，就會列出薪水比主管高的員工。

【講師】第一題的 NULLS LAST 不是 MySQL 支援的語法，現場執行前請先拿掉，或改成 ORDER BY m.name IS NULL, m.name。
-->

---
layout: end
---

# Q & A

有任何問題嗎？

<!--
今天我們學了五種 JOIN，最重要的是 INNER JOIN 和 LEFT JOIN。記住一句話：「INNER JOIN 只取交集，LEFT JOIN 保留左表全部。」再加上 LEFT JOIN 配 IS NULL 的技巧，就能處理大部分的合併查詢。

不過 JOIN 的表一多、資料一大，查詢就可能變慢。下一章，我們要學索引和 EXPLAIN，看看怎麼讓查詢跑得更快。我們下一章見。

【講師】開放提問，可以請同學用自己的話說明 INNER JOIN 和 LEFT JOIN 的差別。
-->
