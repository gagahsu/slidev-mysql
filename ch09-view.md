---
theme: penguin
class: text-center
highlighter: shiki
lineNumbers: true
drawings:
  persist: false
transition: slide-left
title: VIEW 視圖
routeAlias: ch09
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
    VIEW 視圖
  </h1>
  <div style="height: 4px; width: 320px; background: linear-gradient(90deg, #5eada0, #a7d9d0); border-radius: 2px; margin-bottom: 1.5rem;"></div>
  <p style="color: #4a7c7c; font-size: 1.15rem; font-style: italic;">
    「把複雜的查詢包裝起來，下次直接用」
  </p>
  <Link to="home" style="color: #9dc4c4; font-size: 0.85rem; margin-top: 2rem; text-decoration: none; letter-spacing: 0.05em;">← 返回目錄</Link>
</div>

<!--
大家好，歡迎來到第九章——VIEW 視圖！

學到這裡，大家已經能夠寫出各種複雜的 SQL 查詢了。但你有沒有遇過這樣的情況：同一段複雜的 JOIN 查詢，在很多地方都會用到，每次都要重複寫一遍？

VIEW（視圖）就是解決這個問題的工具。

「VIEW 是一張虛擬的資料表，背後是一個 SELECT 查詢。」每次對 VIEW 做查詢，MySQL 就執行背後的 SELECT，把結果呈現為一張表的樣子。

學完這章，大家就能把複雜的查詢邏輯包裝起來，讓 SQL 程式碼更乾淨、更容易維護。
-->

---
layout: default
---

# Outline

- **什麼是 VIEW？** — VIEW 的概念、優點與限制
- **CREATE VIEW 建立視圖** — 基本語法與範例
- **管理 VIEW** — 修改、查看、刪除視圖
- **可更新視圖** — 什麼情況下可以對 VIEW 做 DML
- **VIEW 的使用注意事項** — 效能考量與最佳實踐

<!--
這章的結構很清楚：先說什麼是 VIEW、為什麼用，然後學建立和管理的語法，最後說進階的可更新視圖和使用注意事項。

VIEW 是一個相對好理解的概念，主要的挑戰是了解「什麼時候用 VIEW 是好的選擇」，以及「可更新視圖」的限制。

我們用一個貫穿全章的訂單系統範例，讓大家看到 VIEW 在實際工作中的樣子。
-->

---

# 什麼是 VIEW？

「VIEW（視圖）是一張虛擬的資料表，它的內容由一個 SELECT 查詢定義。VIEW 本身不儲存任何資料，每次查詢 VIEW 時，MySQL 會執行背後的 SELECT。」

| 面向 | 真實資料表（TABLE）| 視圖（VIEW）|
| --- | --- | --- |
| 儲存資料 | ✅ 實際儲存資料 | ❌ 不儲存，每次動態查詢 |
| 可以查詢 | ✅ | ✅ |
| 可以 INSERT/UPDATE | ✅ | ⚠️ 有條件限制 |
| 用途 | 儲存資料 | 簡化查詢、封裝邏輯、存取控制 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>最佳類比：</b>VIEW 就像 Excel 裡的「參照公式」。你看到的是一個格子的值，但它其實是從別的地方計算來的，不是直接儲存在那個格子裡。
</div>

<!--
VIEW 和 TABLE 最大的差別是：TABLE 真正儲存資料，VIEW 只是一個「窗口」，透過它你能看到背後查詢的結果。

想像你有一個 Excel 試算表，有一張原始資料工作表，另外有一張工作表裡全是公式，引用原始資料並做計算。VIEW 就是那張「全是公式的工作表」——它本身沒有資料，但透過它你能看到整理後的資訊。

這個特性決定了 VIEW 的用途：
1. 簡化查詢：把複雜的多表 JOIN 封裝成一個 VIEW，其他人只需要 SELECT * FROM that_view
2. 存取控制：給特定使用者只能查看 VIEW，不讓他們直接存取原始表
3. 封裝業務邏輯：把「有上架的商品中，庫存大於 0 的手機」這個條件封裝到 VIEW 裡
-->

---

# VIEW 的三大優點

| 優點 | 說明 |
| --- | --- |
| **簡化複雜查詢** | 把 JOIN、計算、篩選邏輯封裝起來，使用時只需 `SELECT * FROM view_name` |
| **提升安全性** | 只讓使用者存取 VIEW，不直接暴露底層表結構或敏感欄位 |
| **提高可維護性** | 業務邏輯改變時，只需修改 VIEW 定義，不需要修改所有用到這個查詢的地方 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
⚠️ <b>VIEW 不是效能工具：</b>每次查詢 VIEW，MySQL 都會執行背後的 SELECT。VIEW 不會讓查詢變快，它只是讓「程式碼」更簡潔。
</div>

<!--
讓我特別說明這三個優點的實際意義：

簡化查詢：假設你的報表需要一個複雜的查詢，涉及 customers、orders、order_items、products 四張表的 JOIN，還有一些計算欄位。把這個查詢封裝成 VIEW，報表的 SQL 就變成簡單的 SELECT * FROM monthly_sales_view WHERE month = '2024-01'，任何人都看得懂。

安全性：假設 customers 表有 email、phone、credit_card 等敏感資訊，你可以建立一個 VIEW 只包含 id 和 name，讓客服人員只能查 VIEW，看不到敏感資料。

可維護性：如果「活躍訂單」的定義改變了（例如從 status='active' 改成 status IN ('active', 'pending')），只需要修改 VIEW 定義，所有用到 active_orders_view 的地方都自動更新。

⚠️ 但要記住：VIEW 不會讓查詢變快。如果背後的 SELECT 很慢，VIEW 也會很慢。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第一部分
# CREATE VIEW — 建立視圖

<!--
進入第一部分，學習建立 VIEW 的語法。

語法很簡單，但我們會看幾個實際的使用場景。
-->

---

# CREATE VIEW 的語法結構

```sql
CREATE [OR REPLACE] VIEW view_name
  [(column_list)]
AS
  SELECT ...;
```

建立一個「顯示活躍顧客與其訂單總額」的視圖：

```sql
CREATE VIEW customer_order_summary AS
SELECT
  c.id          AS customer_id,
  c.name        AS customer_name,
  COUNT(o.id)   AS order_count,
  SUM(o.amount) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
WHERE c.is_active = 1
GROUP BY c.id, c.name;
```

<!--
CREATE VIEW 的語法就是在 SELECT 語句前面加上 CREATE VIEW view_name AS。

OR REPLACE 讓你在 VIEW 已存在時直接覆蓋，不需要先 DROP 再 CREATE。這在開發時很方便。

看這個 VIEW 的定義：它把 customers 和 orders 的 JOIN，加上聚合計算，封裝成一個叫 customer_order_summary 的虛擬表。

之後任何人想查顧客的訂單摘要，只需要：SELECT * FROM customer_order_summary WHERE customer_id = 5。

不需要再寫那個複雜的 JOIN + GROUP BY，VIEW 幫你記住了這個查詢邏輯。
-->

---

# 查詢 VIEW

建立 VIEW 後，就像查詢一般資料表一樣使用它：

```sql
-- 查詢 VIEW 的所有資料
SELECT * FROM customer_order_summary;

-- 對 VIEW 加入額外篩選條件
SELECT customer_name, total_spent
FROM customer_order_summary
WHERE total_spent > 10000
ORDER BY total_spent DESC;

-- VIEW 也可以和其他表 JOIN
SELECT v.customer_name, v.total_spent, a.city
FROM customer_order_summary v
JOIN addresses a ON v.customer_id = a.customer_id;
```

<!--
這是 VIEW 最迷人的地方：建立後，它就像一張真正的表，可以 SELECT、可以加 WHERE 條件、可以和其他表 JOIN。

第一個：直接 SELECT * 查看所有顧客的訂單摘要。

第二個：在 VIEW 上加 WHERE 條件，篩選消費總額超過 10000 的顧客。這個 WHERE 條件是在 VIEW 結果上篩選，不影響 VIEW 的定義。

第三個：VIEW 可以和其他表 JOIN！把 customer_order_summary 視圖和 addresses 表 JOIN，取得顧客的城市資訊。

對於使用 VIEW 的人來說，他們完全不需要知道背後是怎麼實作的——這就是封裝的威力。
-->

---

# 另一個 VIEW 範例：安全性控制

只暴露必要的欄位，隱藏敏感資訊：

```sql
-- 原始 customers 表有敏感欄位
-- customers (id, name, email, phone, credit_card_hash, address)

-- 建立一個對外安全的 VIEW
CREATE VIEW public_customers AS
SELECT
  id,
  name,
  LEFT(email, 3) || '***@***.com' AS masked_email
FROM customers
WHERE is_active = 1;
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>實際用途：</b>給客服系統只開放 VIEW 的查詢權限，他們能查詢到客戶資訊，但看不到完整的 email 和信用卡資料。
</div>

<!--
這個例子展示了 VIEW 的安全性用途。

原始 customers 表可能有很多敏感欄位（email、電話、信用卡 hash）。我們不希望所有人都能直接查詢這張表。

建立 public_customers VIEW，只暴露必要的 id 和 name，email 則做遮罩處理（只顯示前三個字元）。

之後可以用 MySQL 的權限系統（GRANT）讓某個資料庫使用者只能存取這個 VIEW，而不能直接存取 customers 表。

這樣客服人員可以透過 VIEW 查到他們需要的客戶資訊，但無法看到完整的敏感資料。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第二部分
# 管理 VIEW

<!--
進入第二部分，學習查看、修改和刪除 VIEW 的方法。
-->

---

# 查看與修改 VIEW

```sql
-- 查看資料庫中所有的 VIEW
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- 查看 VIEW 的定義
SHOW CREATE VIEW customer_order_summary;

-- 修改 VIEW（使用 OR REPLACE 直接覆蓋）
CREATE OR REPLACE VIEW customer_order_summary AS
SELECT
  c.id          AS customer_id,
  c.name        AS customer_name,
  c.email,
  COUNT(o.id)   AS order_count,
  SUM(o.amount) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
WHERE c.is_active = 1
GROUP BY c.id, c.name, c.email;

-- 刪除 VIEW
DROP VIEW IF EXISTS customer_order_summary;
```

<!--
管理 VIEW 的語法和管理 TABLE 很類似。

SHOW FULL TABLES WHERE Table_type = 'VIEW' 列出所有的 VIEW，過濾掉真正的資料表。這在資料庫有很多表和 VIEW 時很有用，讓你快速找到所有 VIEW。

SHOW CREATE VIEW 顯示 VIEW 的完整定義，和 SHOW CREATE TABLE 的輸出類似。

修改 VIEW 最簡單的方式是用 CREATE OR REPLACE VIEW——直接覆蓋原來的定義，不需要先 DROP 再 CREATE。

DROP VIEW IF EXISTS 安全地刪除 VIEW，如果不存在也不報錯。

⚠️ 注意：刪除 VIEW 不會影響底層的資料表，只是移除了這個「窗口」的定義。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第三部分
# 可更新視圖與注意事項

<!--
最後一個部分，我們說兩個進階主題：可更新視圖，以及使用 VIEW 的注意事項。

可更新視圖是很多人不知道的功能，但它有嚴格的限制，要小心使用。
-->

---

# 可更新視圖（Updatable View）

某些 VIEW 允許透過 VIEW 對底層資料表執行 INSERT、UPDATE、DELETE：

```sql
-- 建立一個簡單的可更新 VIEW
CREATE VIEW active_products AS
SELECT id, name, price, stock
FROM products
WHERE is_active = 1;

-- 透過 VIEW 更新底層資料
UPDATE active_products
SET price = 24900.00
WHERE id = 5;

-- 透過 VIEW 刪除底層資料（會刪除 products 表的對應列）
DELETE FROM active_products WHERE id = 5;
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>注意：</b>透過 VIEW 執行的 DML，實際上是作用在底層資料表，不是在 VIEW 本身。
</div>

<!--
可更新視圖讓我們能透過 VIEW 修改底層資料，這在某些情況下很方便。

但要記住：透過 VIEW 執行 UPDATE 或 DELETE，實際上是修改底層的 products 表。VIEW 只是一個「透明的窗口」，寫入的資料流向底層表。

一個有趣的細節：如果 VIEW 有 WHERE 條件（如 WHERE is_active = 1），你可以透過 VIEW UPDATE 一筆原本符合條件的資料，讓它變成不符合條件（例如把 is_active 設為 0）。更新後，這筆資料就從 VIEW 裡「消失」了（因為不再符合 WHERE 條件），但在底層 products 表還是存在的。這有時候會讓人困惑。

可以用 WITH CHECK OPTION 來防止這種情況：WITH CHECK OPTION 確保透過 VIEW 修改的資料仍然符合 VIEW 的 WHERE 條件。
-->

---

# VIEW 的不可更新情況

以下類型的 VIEW 是唯讀的，不支援 INSERT / UPDATE / DELETE：

| 情況 | 說明 |
| --- | --- |
| 包含 `DISTINCT` | 無法映射到唯一一筆底層資料 |
| 包含聚合函式 | `COUNT`、`SUM`、`AVG` 等計算出來的值無法反向更新 |
| 包含 `GROUP BY` | 分組後的結果無法對應到單筆資料 |
| 包含 `UNION` | 多個查詢的合併結果無法確定來源 |
| 包含子查詢 | 複雜的來源無法確定更新目標 |
| 涉及多張表的 JOIN | 無法確定 DML 應該更新哪張表 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>判斷原則：</b>如果 VIEW 的每一列都能對應到底層表的唯一一列，它通常是可更新的；如果不能，就是唯讀的。
</div>

<!--
大多數複雜的 VIEW 都是唯讀的。

最直觀的例子：如果 VIEW 裡有 COUNT(*) AS order_count，這個欄位是計算出來的，你不能透過修改 VIEW 的 order_count 來改變底層的訂單數量——你要真的 DELETE FROM orders 才行。

包含 GROUP BY 的 VIEW（例如我們前面建立的 customer_order_summary）也是唯讀的，因為它的每一列對應的是「多筆訂單的摘要」，而不是一筆特定的底層資料。

多表 JOIN 的可更新性比較複雜：某些簡單的 JOIN（例如只取一張表的欄位）可能可以更新，但複雜的多表 JOIN 通常不行。

實際工作中，如果需要透過 VIEW 做 DML，建議先實際測試，確認 MySQL 是否允許，不要假設它可以。
-->

---

# VIEW 的效能考量

VIEW 讓程式碼更乾淨，但要注意效能問題：

| 情境 | 說明 |
| --- | --- |
| VIEW 是簡單查詢 | 效能和直接查詢相同 |
| VIEW 包含複雜 JOIN | 每次查詢都重新執行 JOIN，無快取 |
| 對 VIEW 加 WHERE 條件 | MySQL 有時能「推入」條件（Predicate Pushdown）最佳化 |
| VIEW 套 VIEW | 巢狀 VIEW 效能差，盡量避免 |

```sql
-- 避免：對複雜 VIEW 再次做複雜查詢
SELECT * FROM complex_view WHERE col IN (
  SELECT id FROM another_view WHERE ...
);

-- 建議：直接查詢底層表，使用正確的索引
SELECT ... FROM base_table1 JOIN base_table2 ...
WHERE ... AND ...;
```

<!--
VIEW 最大的效能陷阱是「每次查詢都重新執行」。

VIEW 不儲存資料，也不快取查詢結果。每次你 SELECT * FROM complex_view，MySQL 就把 VIEW 的定義展開，執行那個複雜的 SQL，然後把結果回傳給你。

如果 VIEW 背後是一個涉及 4 張表 JOIN 的查詢，你每次查詢都在執行那個 4 表 JOIN。在大資料量下，這可能很慢。

特別要避免的是「VIEW 套 VIEW」——例如 VIEW A 建立在 VIEW B 上，VIEW B 又建立在 VIEW C 上。MySQL 需要展開所有層次，查詢規劃變得非常複雜，效能可能很差。

如果你需要快取查詢結果，考慮使用「物化視圖」（Materialized View）——但 MySQL 原生不支援物化視圖，你需要手動建立一張實體表，用排程任務定期更新。
-->

---

# 總結

本章學了 VIEW 視圖的核心概念：

- **VIEW 是什麼** — 虛擬資料表，背後是 SELECT 查詢，不儲存資料
- **三大優點** — 簡化複雜查詢、提升安全性（欄位遮罩）、提高可維護性
- **CREATE VIEW** — `CREATE [OR REPLACE] VIEW name AS SELECT ...`
- **查看與管理** — `SHOW FULL TABLES`、`SHOW CREATE VIEW`、`DROP VIEW`
- **可更新視圖** — 單表、無聚合、無 GROUP BY 的簡單 VIEW 可以做 DML
- **效能注意** — VIEW 不快取結果，複雜 VIEW + 大資料量可能很慢

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
🚀 <b>課程完成！</b>恭喜大家！從資料庫設計原則到 VIEW，我們走完了 MySQL 最重要的基礎課程。繼續學習：Stored Procedure、Transaction、Window Functions！
</div>

<!--
學完這章，大家已經學會了 VIEW 這個讓程式碼更乾淨的工具。

VIEW 最適合的使用場景：
1. 有一個複雜的 JOIN 查詢會在很多地方重複使用
2. 需要對不同的人/系統提供不同層次的資料存取控制
3. 業務邏輯封裝（例如「活躍商品」的定義）

VIEW 不適合的場景：
1. 為了提升效能（VIEW 不做快取）
2. 頻繁需要 INSERT/UPDATE 的場景（大多數複雜 VIEW 是唯讀的）

恭喜大家完成了 MySQL 基礎課程的九個章節！
做兩道練習，把今天的 VIEW 知識鞏固一下。
-->

---
layout: default
---

# 練習 1：任務說明
### 建立報表 VIEW

有以下資料表：

```sql
-- orders (id, customer_id, status, amount, order_date)
-- customers (id, name, email)
-- order_items (order_id, product_id, quantity)
-- products (id, name, category, price)
```

**任務：**
1. 建立 `monthly_revenue_view`：顯示每月的訂單數量和總收入（只含 `completed` 狀態）
2. 建立 `top_products_view`：顯示每個商品的總銷售數量，按數量降冪排列
3. 對 `monthly_revenue_view` 執行查詢，找出 2024 年收入最高的三個月

<!--
這三個任務考驗 VIEW 在報表場景的應用。

第一個：GROUP BY YEAR(order_date), MONTH(order_date) + WHERE status = 'completed'

第二個：JOIN order_items 和 products，GROUP BY product，SUM(quantity) 計算總銷售

第三個：建立好第一個 VIEW 後，對它執行 SELECT + WHERE YEAR = 2024 + ORDER BY + LIMIT 3
-->

---
layout: default
---

# 練習 1：解題提示

```sql
-- 1. 每月收入 VIEW
CREATE OR REPLACE VIEW monthly_revenue_view AS
SELECT
  YEAR(order_date)   AS year,
  MONTH(order_date)  AS month,
  COUNT(*)           AS order_count,
  SUM(amount)        AS revenue
FROM orders
WHERE status = 'completed'
GROUP BY YEAR(order_date), MONTH(order_date);

-- 2. 商品銷售排行 VIEW
CREATE OR REPLACE VIEW top_products_view AS
SELECT
  p.id, p.name, p.category,
  SUM(oi.quantity) AS total_sold
FROM products p
JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id, p.name, p.category
ORDER BY total_sold DESC;
```

<!--
解答分析：

monthly_revenue_view：GROUP BY YEAR + MONTH，配合 WHERE status = 'completed'。注意這兩個欄位都要列在 GROUP BY 裡。

top_products_view：JOIN products 和 order_items，用 SUM(oi.quantity) 計算每個商品的總銷售數量。注意 p.id、p.name、p.category 都要在 GROUP BY 裡（因為它們不是聚合函式）。
-->

---

# 練習 1：解題提示（續）

```sql
-- 3. 查詢 VIEW：2024 年收入最高的三個月
SELECT year, month, revenue
FROM monthly_revenue_view
WHERE year = 2024
ORDER BY revenue DESC
LIMIT 3;
```

<!--
第三個任務展示了 VIEW 的便利：複雜的分組邏輯已經封裝在 VIEW 裡，查詢 VIEW 的 SQL 非常簡單易讀。

⚠️ 這兩個 VIEW 都包含 GROUP BY 和聚合函式，所以它們是唯讀的（不可更新）。
-->

---
layout: default
---

# 練習 2：任務說明
### 安全性 VIEW 設計

你的公司有一張 `employees` 表：

```sql
CREATE TABLE employees (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(100) NOT NULL,
  department VARCHAR(100) NOT NULL,
  salary     DECIMAL(10,2) NOT NULL,
  ssn        VARCHAR(20) NOT NULL,
  manager_id INT,
  hire_date  DATE NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**任務：**
1. 建立 `public_employees_view`：讓一般員工只能看到 id、name、department（不能看薪資和身份證字號）
2. 建立 `hr_employees_view`：讓 HR 能看到所有資訊，但 ssn 只顯示後四碼（`****XXXX`）
3. 說明為什麼這些 VIEW 比直接給查詢權限更安全

<!--
這題考驗 VIEW 在安全性方面的應用。

提示：可以用 RIGHT(ssn, 4) 取最後四碼，然後用 CONCAT('****', RIGHT(ssn, 4)) 組合遮罩後的身份證字號。

思考第三題：如果直接給某個資料庫帳號 SELECT 權限，他能看到所有欄位；但如果只給他 VIEW 的 SELECT 權限，他只能看到 VIEW 定義的欄位。
-->

---
layout: default
---

# 練習 2：解題提示

```sql
-- 1. 一般員工 VIEW（隱藏薪資和身份證）
CREATE OR REPLACE VIEW public_employees_view AS
SELECT
  id,
  name,
  department,
  hire_date
FROM employees;

-- 2. HR VIEW（薪資顯示，身份證遮罩）
CREATE OR REPLACE VIEW hr_employees_view AS
SELECT
  id,
  name,
  department,
  salary,
  CONCAT('****', RIGHT(ssn, 4)) AS masked_ssn,
  manager_id,
  hire_date
FROM employees;
```

<!--
解答分析：

public_employees_view：只 SELECT 需要的欄位（id、name、department、hire_date），完全不包含 salary 和 ssn。

hr_employees_view：可以看到 salary，但 ssn 用 CONCAT('****', RIGHT(ssn, 4)) 遮罩成 ****1234 的格式。HR 知道員工有身份證，但看不到完整號碼。
-->

---

# 練習 2：解題提示（續）

```sql
-- 3. 授予只讀 VIEW 的權限（DCL）
GRANT SELECT ON company_db.public_employees_view
  TO 'regular_user'@'%';
```

<!--
安全性的原因：透過 GRANT 語法，你可以精細地控制「哪個使用者可以存取哪個 VIEW」。就算資料庫被入侵，攻擊者拿到的是 regular_user 帳號，他只能查 public_employees_view，看不到薪資和身份證。

這是「最小權限原則」（Principle of Least Privilege）在資料庫上的應用——每個使用者只給他真正需要的最小權限。
-->

---
layout: end
---

# Q & A

有任何問題嗎？

<!--
現在開放 Q&A 時間。

大家對 VIEW 有沒有什麼疑問？

最重要的觀念：VIEW 是「簡化程式碼和控制存取的工具」，不是「提升效能的工具」。

恭喜大家完成了九個章節！MySQL 的基礎課程到這裡告一段落。

如果大家想繼續深入，接下來可以學習：
- Stored Procedure（預存程序）
- Transaction（交易管理）
- Window Functions（視窗函式）
- Trigger（觸發器）

感謝大家的參與！
-->
