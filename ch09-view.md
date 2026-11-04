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
大家好，歡迎來到第九章：VIEW 視圖。

學到這裡，大家已經能寫出很複雜的查詢了。不過同一段複雜的查詢，報表要用、後台也要用，每次都得重寫一遍，改規則時還得到處找。

VIEW 就是為了解決這個問題。它能把一段複雜的查詢包裝起來，取一個名字，下次直接拿來用。學完這章，大家寫出來的 SQL 會更乾淨，也更好維護。
-->

---
layout: default
---

# Outline

- **什麼是 VIEW？** — VIEW 的概念、優點與限制
- **CREATE VIEW 建立視圖** — 基本語法與範例
- **管理 VIEW** — 修改、查看、刪除視圖
- **VIEW 的使用注意事項** — 效能考量

<!--
這一章先認識 VIEW 是什麼，有哪些優點和限制。接著學怎麼建立 VIEW，以及查看、修改、刪除的管理方式。最後看使用 VIEW 時要注意的效能問題。

整章會延續我們熟悉的顧客和訂單範例。
-->

---

# 什麼是 VIEW？

「VIEW（視圖）是一張虛擬的資料表，它的內容由一個 SELECT 查詢定義。VIEW 本身不儲存任何資料，每次查詢 VIEW 時，MySQL 會執行背後的 SELECT。」

| 面向 | 真實資料表（TABLE）| 視圖（VIEW）|
| --- | --- | --- |
| 儲存資料 | ✅ 實際儲存資料 | ❌ 不儲存，每次動態查詢 |
| 可以查詢 | ✅ | ✅ |
| 可以 INSERT/UPDATE | ✅ | ⚠️ 有條件限制（本課程只用來查詢）|
| 用途 | 儲存資料 | 簡化查詢、封裝邏輯、存取控制 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>最佳類比：</b>VIEW 就像 Excel 裡的「參照公式」。你看到的是一個格子的值，但它其實是從別的地方計算來的，不是直接儲存在那個格子裡。
</div>

<!--
「VIEW 是一張虛擬的資料表，它的內容由一個 SELECT 查詢定義。VIEW 本身不儲存任何資料，每次查詢 VIEW 時，MySQL 會執行背後的 SELECT。」

我們用 Excel 來想像。一份試算表裡，有一張工作表放原始資料，另一張工作表全是公式，引用原始資料並整理成報表。那張全是公式的工作表，本身沒存資料，打開時才即時算出結果。VIEW 就是這樣的東西。

表格比較了它和資料表的差別。資料表真的存資料，VIEW 只是一扇窗。兩者都能查詢，但 VIEW 要修改資料會有很多條件限制，所以這門課我們只用它來查詢。
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
表格列出了 VIEW 的三大優點。

第一是簡化查詢。假設月報表要 JOIN 四張表，還要計算欄位，把它包成 VIEW 之後，報表的 SQL 只剩一行 SELECT，任何人都看得懂。

第二是安全性。顧客表裡可能有電話、信用卡這些敏感資料，我們可以建一個只有編號和姓名的 VIEW，讓客服只能查這個 VIEW。

第三是可維護性。如果「有效訂單」的定義改了，只要修改 VIEW 這一個地方，所有用到它的查詢都會跟著更新。

不過要特別提醒，VIEW 不是效能工具。每次查詢 VIEW，背後的 SELECT 都會重新執行。原本的查詢很慢，包成 VIEW 也一樣慢。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第一部分
# CREATE VIEW — 建立視圖

<!--
接下來我們動手建立 VIEW。語法很簡單，重點是看它在實際場景裡怎麼用。
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
上面是 VIEW 的語法結構，其實就是在 SELECT 前面加上 `CREATE VIEW` 名稱 `AS`。方括號裡的 `OR REPLACE` 是選用的，如果 VIEW 已經存在，就直接覆蓋，不用先刪除再建立。

下面的範例建立了一個叫 `customer_order_summary` 的 VIEW，要做的是統計每位有效顧客的訂單數和消費總額。

它的內容大家應該很熟悉，用 LEFT JOIN 把顧客和訂單接起來，篩選有效顧客，再依顧客分組，算出訂單數和總金額。用 LEFT JOIN 是為了讓沒下過單的顧客也會出現。

執行後，資料庫裡就多了一張虛擬表。之後想查顧客的消費摘要，不用再寫這整段 JOIN 加分組，直接查這個 VIEW 就可以了。
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
VIEW 建好之後，用起來就跟一般的資料表一樣。

第一個查詢直接 `SELECT *`，執行後會列出所有有效顧客的訂單數和消費總額。

第二個查詢在 VIEW 上再加條件，篩選消費超過一萬元的顧客，並依金額由高到低排列。這個 WHERE 是對 VIEW 的結果做篩選，不會改變 VIEW 本身的定義。

第三個查詢把 VIEW 跟地址表 `addresses` JOIN 起來，取得顧客所在的城市。

使用 VIEW 的人，完全不需要知道它背後是怎麼寫的。這就是封裝的好處，複雜的邏輯藏起來，留下簡單好用的介面。
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
  CONCAT(LEFT(email, 3), '***@***.com') AS masked_email
FROM customers
WHERE is_active = 1;
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>實際用途：</b>給客服系統只開放 VIEW 的查詢權限，他們能查詢到客戶資訊，但看不到完整的 email 和信用卡資料。
</div>

<!--
這個範例示範 VIEW 的另一個用途，就是保護敏感資料。

原本的顧客表裡有 email、電話、信用卡資料這些敏感欄位。我們建立一個叫 `public_customers` 的 VIEW，只放顧客編號和姓名，email 則做遮罩。`LEFT(email, 3)` 取出前三個字元，`CONCAT` 再接上一串星號，把後面蓋住。

接著用 MySQL 的權限設定，讓客服系統的帳號只能查詢這個 VIEW，不能直接碰原本的顧客表。這樣客服查得到需要的資訊，卻看不到完整的 email 和信用卡資料。

這裡有個常見的坑。有些資料庫用兩條直線串接字串，但在 MySQL 裡，兩條直線預設是邏輯的 OR，所以串接字串一定要用 `CONCAT`。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第二部分
# 管理 VIEW

<!--
VIEW 建立之後，還需要查看、修改和刪除。我們來看管理的方式。
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
管理 VIEW 的語法，跟管理資料表很像。

第一行 `SHOW FULL TABLES`，加上類型等於 VIEW 的條件，就能只列出資料庫裡所有的 VIEW。資料表一多的時候，這個很好用。第二行 `SHOW CREATE VIEW` 會顯示這個 VIEW 完整的定義內容。

要修改 VIEW，最簡單的方法是 `CREATE OR REPLACE VIEW`。範例在原本的定義裡多加了 email 欄位，執行後就直接覆蓋掉舊的版本。要注意 GROUP BY 也要跟著加上 email。

最後是 `DROP VIEW IF EXISTS`，用來刪除 VIEW。

刪除 VIEW 不會影響底層的資料表。我們只是拆掉了這扇窗，窗外的資料都還在。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第三部分
# 使用 VIEW 的注意事項

<!--
VIEW 用起來很方便，但它不是萬能的。最後我們來看使用時要注意的效能問題。
-->

---

# VIEW 的效能考量

VIEW 讓程式碼更乾淨，但要注意效能問題：

| 情境 | 說明 |
| --- | --- |
| VIEW 是簡單查詢 | 效能和直接查詢相同 |
| VIEW 包含複雜 JOIN | 每次查詢都重新執行 JOIN，無快取 |
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
最後來看效能。VIEW 讓程式碼變乾淨，但有一個陷阱：它不儲存資料，也不會快取結果。

所以表格第二列提到，如果 VIEW 背後是四張表的 JOIN，每次查詢都會重新執行一次這個 JOIN，資料量大時就可能很慢。

特別要避免的是 VIEW 套 VIEW，也就是一個 VIEW 建立在另一個 VIEW 上，一層套一層。MySQL 要全部展開才能執行，效能很難掌握。程式碼裡的對照，就是建議這種情況直接查詢底層表，搭配上一章學的索引。
-->

---

# 總結

本章學了 VIEW 視圖的核心概念：

- **VIEW 是什麼** — 虛擬資料表，背後是 SELECT 查詢，不儲存資料
- **三大優點** — 簡化複雜查詢、提升安全性（欄位遮罩）、提高可維護性
- **CREATE VIEW** — `CREATE [OR REPLACE] VIEW name AS SELECT ...`
- **查看與管理** — `SHOW FULL TABLES`、`SHOW CREATE VIEW`、`DROP VIEW`
- **效能注意** — VIEW 不快取結果，複雜 VIEW + 大資料量可能很慢

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
🚀 <b>下一章：</b>我們將學習子查詢，把一個查詢的結果，當成另一個查詢的條件！
</div>

<!--
我們整理這一章。VIEW 是一張虛擬資料表，背後是一個 SELECT，本身不存資料。它有三大優點：簡化查詢、保護敏感資料、集中管理業務邏輯。我們學了用 `CREATE OR REPLACE VIEW` 建立和修改，用 `SHOW` 查看，用 `DROP VIEW` 刪除。

最後要記得，VIEW 不會讓查詢變快，也要避免一層套一層。

接下來，我們用兩題練習把 VIEW 練熟。
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
第一題，我們用訂單、顧客、訂單明細和商品四張表，建立報表用的 VIEW。

任務有三個。第一，建立 `monthly_revenue_view`，顯示每個月已完成訂單的數量和總收入。第二，建立 `top_products_view`，統計每個商品總共賣出多少件。第三，查詢第一個 VIEW，找出 2024 年收入最高的三個月。

可以想想看，建好 VIEW 之後，第三個任務的查詢會變得多簡單？

我們先暫停一下，動手寫寫看。

【講師】給大家十分鐘，可以提醒前兩個任務就是前面 DQL 那一章學過的分組統計。
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
我們來看前兩個 VIEW 的解答。

`monthly_revenue_view` 先用 WHERE 篩選已完成的訂單，再用 `YEAR` 和 `MONTH` 依年月分組，算出訂單數和收入總和。年和月兩個都要列在 GROUP BY 裡。

`top_products_view` 把商品表和訂單明細 JOIN 起來，用 `SUM(oi.quantity)` 算出每個商品總共賣了幾件。這裡 SELECT 了商品的編號、名稱和分類，它們都不是聚合函式，所以也都要列在 GROUP BY 裡。

執行後，資料庫裡就多了兩張報表用的虛擬表，可以直接拿來查詢。
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
第三個任務展示了 VIEW 的便利。複雜的分組邏輯已經包在 VIEW 裡，現在只要從 `monthly_revenue_view` 篩選 2024 年，依收入由高到低排序，取前三筆就好。

執行後，就能看到 2024 年收入最高的三個月。

同樣的需求，如果沒有 VIEW，每次都得把分組統計整段重寫一遍。有了 VIEW，查詢就簡單多了。
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
第二題是設計安全性的 VIEW。這張員工表裡有薪資和身分證字號這些敏感資料。

任務有三個。第一，建立一個給一般員工看的 VIEW，只能看到編號、姓名和部門，看不到薪資和身分證字號。第二，建立一個給人資部門的 VIEW，可以看到所有資訊，但身分證字號只顯示後四碼。第三，說明為什麼用 VIEW 比直接開放資料表權限更安全。

可以想想看，要取出字串的最後四個字元，再在前面補上星號，該用哪些函式？

我們先暫停一下，自己寫寫看。

【講師】給大家十分鐘，可以提示 RIGHT 和 CONCAT 這兩個函式。
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
  department
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
我們來看前兩個 VIEW。

`public_employees_view` 很單純，只 SELECT 需要公開的欄位，編號、姓名和部門，完全不包含薪資和身分證字號。

`hr_employees_view` 保留了薪資，身分證字號則用 `CONCAT('****', RIGHT(ssn, 4))` 處理。`RIGHT` 取出最後四碼，`CONCAT` 再在前面接上四個星號。

執行後，人資查到的會是四個星號加上後四碼，知道是哪個人，卻看不到完整的號碼。
-->

---

# 練習 2：解題提示（續）

```sql
-- 3. 授予只讀 VIEW 的權限（DCL）
GRANT SELECT ON company_db.public_employees_view
  TO 'regular_user'@'%';
```

<!--
第三個任務要說明，為什麼這樣比較安全。

關鍵在權限。畫面上的 `GRANT SELECT` 只把 `public_employees_view` 的查詢權限給了一般使用者的帳號。就算這個帳號外洩，拿到它的人也只能查這個 VIEW，看不到薪資和身分證。

這就是「最小權限原則」：每個使用者只拿到他真正需要的權限。
-->

---
layout: end
---

# Q & A

有任何問題嗎？

<!--
今天我們學了 VIEW。它能簡化查詢、保護敏感資料、集中管理邏輯，但要記住，VIEW 是讓程式碼更乾淨、更安全的工具，不是讓查詢變快的工具。

下一章，我們要學子查詢，把一個查詢的結果，當成另一個查詢的條件或資料來源。我們下一章見。

【講師】開放提問，也可以請同學想想自己的專案裡，哪段查詢適合包成 VIEW。
-->
