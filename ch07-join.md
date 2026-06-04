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
大家好，歡迎來到第七章——JOIN 合併查詢！

前幾章我們學了如何設計資料庫結構，讓不同的資料存在不同的表裡。但這帶來了一個新問題：如果想同時看到多張表的資料，該怎麼辦？

這就是 JOIN 要解決的問題。「JOIN 的作用，就是把兩張或多張有關聯的資料表，根據共同欄位合併成一張結果。」

學完這章，大家就能把原本分散在不同表的資料，用一個 SQL 查詢出來。
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
這章有六個部分，每種 JOIN 類型各一個部分。

JOIN 的種類看起來很多，但理解了 INNER JOIN 和 LEFT JOIN，其他的就都容易了。

我會用一個貫穿全章的訂單系統範例，讓大家在同一個資料集上看到各種 JOIN 的差異。

特別推薦大家把每種 JOIN 的「集合圖」概念記在腦海裡——左圓、右圓、交集，對應不同的 JOIN 類型。
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
這是本章所有範例的資料基礎。

customers 表有三個顧客：Alice、Bob、Carol。
orders 表有三筆訂單：兩筆屬於 Alice，一筆的 customer_id 是 NULL（代表顧客未知）。

注意：Carol 沒有任何訂單，而 orders 裡有一筆沒有對應顧客的訂單。

這個設計讓我們能清楚看到不同 JOIN 類型的差異——特別是 NULL 值在各種 JOIN 下的行為。

大家先把這個資料結構記住，接下來所有範例都在這個基礎上操作。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第一部分
# INNER JOIN

<!--
進入第一部分：INNER JOIN。

INNER JOIN 是最常用的 JOIN 類型，也是初學者最先學習的。

先說結論：INNER JOIN 只回傳「兩張表都有對應資料」的那些筆資料。
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
INNER JOIN 的核心邏輯是「交集」——兩張表都有的才保留。

在我們的範例裡，只有 Alice（id=1）在兩張表都有記錄：customers 表有 Alice，orders 表有兩筆 customer_id=1 的訂單。

Bob 雖然在 customers 表，但 orders 表裡沒有他的訂單，所以 Bob 不會出現在 INNER JOIN 的結果裡。

Carol 同理，沒有訂單所以不出現。

customer_id=NULL 的訂單，找不到對應的顧客，也不出現。

這是 INNER JOIN 最重要的特性：「兩邊都有才保留。」
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
看這段 SQL，有幾個重點要注意：

FROM customers c：用 c 作為 customers 表的別名。別名讓 SQL 更簡潔，在多表 JOIN 時非常重要。

INNER JOIN orders o ON c.id = o.customer_id：ON 後面指定連接條件——customers 的 id 要等於 orders 的 customer_id。

SELECT c.name, o.id, o.amount：欄位前加表別名，這在兩張表有同名欄位時（例如都有 id）是必要的，不然 MySQL 不知道你要哪張表的欄位。

⚠️ 常見錯誤：ON 後面的條件寫錯，例如寫成 ON c.id = c.customer_id（兩邊都用 c 前綴），結果會是奇怪的自身 JOIN。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第二部分
# LEFT JOIN

<!--
進入第二部分：LEFT JOIN。

LEFT JOIN 是實際工作中用得非常多的 JOIN 類型，特別是「需要保留某張表所有資料」的場景。
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
LEFT JOIN 的核心：「左表的所有資料都要保留，右表沒有對應的地方補 NULL。」

在我們的範例裡，以 customers 為左表：
- Alice 有訂單，正常顯示
- Bob 沒有訂單，但 Bob 還是會出現在結果裡，只是 order_id 和 amount 是 NULL
- Carol 沒有訂單，同 Bob

這就是 LEFT JOIN 和 INNER JOIN 的關鍵差別：LEFT JOIN 讓 Bob 和 Carol 也出現在結果裡。

最常用的技巧是「LEFT JOIN + WHERE 右表欄位 IS NULL」——這讓我們能找出「左表有、右表沒有」的記錄，例如「從未下訂的顧客」。
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
兩個範例展示了 LEFT JOIN 最常用的兩種模式。

第一個：完整的 LEFT JOIN，所有顧客都出現，有訂單的顯示金額，沒訂單的 order_id 和 amount 是 NULL。

第二個：「LEFT JOIN + WHERE IS NULL」找出「沒有訂單的顧客」。邏輯是：LEFT JOIN 後，沒有訂單的顧客 order_id 是 NULL；WHERE o.id IS NULL 只保留這些 NULL 的列，也就是沒有訂單的顧客。

這個「LEFT JOIN + IS NULL」的模式非常常用。例如：找出沒有上傳大頭貼的使用者、找出從未被借閱的書籍、找出沒有庫存記錄的商品。

⚠️ 注意：WHERE 條件要用右表的欄位加 IS NULL，不是左表的欄位。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第三部分
# RIGHT JOIN

<!--
進入第三部分：RIGHT JOIN。

RIGHT JOIN 是 LEFT JOIN 的鏡像版本：保留右表所有資料，左表沒有對應的補 NULL。

坦白說，RIGHT JOIN 在實際工作中比較少用——因為你通常可以交換兩張表的位置，用 LEFT JOIN 達到同樣效果。但了解它仍然重要。
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
RIGHT JOIN 以 orders 為右表，保留所有訂單：
- Alice 的兩筆訂單正常顯示
- customer_id=NULL 的訂單也會出現，但 customer_name 是 NULL（找不到對應顧客）
- Bob 和 Carol 因為在左表（customers），RIGHT JOIN 不會多取他們

所以 RIGHT JOIN 的結果是「所有訂單都保留，顧客資訊如果找不到就填 NULL」。

實際上，大多數人更喜歡用 LEFT JOIN，把 RIGHT JOIN 的效果改寫成 LEFT JOIN。例如這個 RIGHT JOIN 等同於：SELECT ... FROM orders o LEFT JOIN customers c ON c.id = o.customer_id。只要交換兩張表的位置，RIGHT JOIN 就變成 LEFT JOIN 了。

兩種寫法效果完全一樣，大多數工程師選擇 LEFT JOIN 是因為閱讀習慣（從左到右）。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第四部分
# CROSS JOIN 與 Self JOIN

<!--
最後兩種 JOIN：CROSS JOIN 和 Self JOIN。

這兩種在日常工作中比前三種少見，但有它們特定的使用場景。
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
CROSS JOIN 就是「笛卡兒積」——數學裡的集合乘積。

最直觀的例子：服裝電商的商品規格。如果有 3 種顏色（紅、藍、黑）和 3 種尺寸（S、M、L），那所有可能的規格組合就是 3 × 3 = 9 種。用 CROSS JOIN 就能一次生成所有組合，不用手動列舉。

⚠️ 最大的危險是忘記 CROSS JOIN 沒有 ON 條件。如果你把 INNER JOIN 的 ON 條件漏掉，MySQL 會把它當成 CROSS JOIN，結果可能是幾百萬筆資料。這是初學者很容易踩到的坑。

如果你看到一個查詢的結果筆數比預期多很多，很可能就是漏了 ON 條件。
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
Self JOIN 是把一張表和自己合併。

什麼情況下需要這樣做？最常見的是「樹狀或階層關係」存在同一張表裡。

員工表的例子：每個員工有一個 manager_id，指向同一張表裡另一個員工的 id。要查詢「每個員工和他的主管姓名」，就需要 Self JOIN——一邊代表員工，另一邊代表主管，但兩邊都是 employees 表。

必須用別名（e 和 m）讓 MySQL 知道你在說哪一個「版本」的 employees 表。

LEFT JOIN（而不是 INNER JOIN）讓最高層的主管（沒有 manager_id 的員工）也出現在結果裡，不然最頂層的人就找不到了。
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
這是五種 JOIN 類型的總整理。

在實際工作中，INNER JOIN 和 LEFT JOIN 用的頻率遠超其他類型：

INNER JOIN：當你確定兩邊都有資料，只需要有關聯的記錄。例如：查詢訂單及其對應的顧客名稱（只顯示顧客存在的訂單）。

LEFT JOIN：當你需要保留某一邊的所有資料，另一邊可能沒有對應。例如：查詢所有顧客（含沒有訂單的），或查詢「某條件為空」的記錄。

記住一個原則：「從哪張表出發，就把那張表放在 LEFT JOIN 的左邊。」

做兩道練習，把今天的內容鞏固一下！
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
學完這章，大家已經能夠用 JOIN 把分散在多張表的資料合在一起查詢了。

最重要的兩個 JOIN：INNER JOIN（取交集）和 LEFT JOIN（保留左表）。

LEFT JOIN + WHERE IS NULL 這個組合特別值得記住，它能幫你找出「沒有對應關聯的記錄」，在實際工作中非常常用。

做兩道練習！
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
這三題難度遞增。

第一題是基本的 INNER JOIN，確認大家理解 ON 條件怎麼寫。

第二題是 LEFT JOIN + IS NULL 的應用，找出「左表有但右表沒有」的記錄。

第三題需要連 JOIN 三張表：orders JOIN order_items JOIN products。

提示：多表 JOIN 可以連續寫多個 JOIN 子句。
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
解答分析：

題一：INNER JOIN 連接顧客和訂單，WHERE status = 'completed' 篩選已完成訂單。

題二：LEFT JOIN 保留所有顧客，WHERE o.id IS NULL 過濾出右表（orders）沒有對應記錄的顧客，就是從未下訂的顧客。

題三：連續兩個 INNER JOIN，把三張表串起來：
orders → order_items（透過 order_id）
order_items → products（透過 product_id）

⚠️ 多表 JOIN 時，一定要用表別名前綴所有欄位，避免 MySQL 不知道你要哪張表的欄位（例如三張表都有 id）。
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
這兩題都需要 Self JOIN。

第一題：用 LEFT JOIN 確保沒有主管的員工也出現（最高層主管的 manager_id 是 NULL）。

第二題要比較同一張表裡兩筆資料的值。

提示：JOIN employees e（員工）ON e.manager_id = m.id JOIN employees m（主管）WHERE e.salary > m.salary。
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
解答分析：

題一：用 LEFT JOIN 確保最頂層的主管（manager_id = NULL）也會出現，其 manager_name 顯示 NULL。

別名 e（員工版本）和 m（主管版本）讓 MySQL 能區分同一張表的兩個「身份」。

題二：用 INNER JOIN 而非 LEFT JOIN，因為我們只需要「有主管」的員工。ON e.manager_id = m.id 建立員工和主管的對應，WHERE e.salary > m.salary 篩選薪資高於主管的員工。

⚠️ 題一用 LEFT JOIN 是因為最頂層主管沒有 manager_id（是 NULL），INNER JOIN 會把他們排除掉。題二用 INNER JOIN 是因為我們只關心「有主管可以比較」的情況。
-->

---
layout: end
---

# Q & A

有任何問題嗎？

<!--
現在開放 Q&A 時間。

大家對 JOIN 有沒有什麼疑問？

最容易搞混的是 INNER JOIN 和 LEFT JOIN 的差別——記住：「INNER JOIN 只取交集，LEFT JOIN 保留左表全部。」

下一章我們會學 Index 和 EXPLAIN，了解如何讓 JOIN 查詢跑得更快！
-->
