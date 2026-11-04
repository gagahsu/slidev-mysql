---
theme: penguin
class: text-center
highlighter: shiki
lineNumbers: true
drawings:
  persist: false
transition: slide-left
title: DML 資料操作語言
routeAlias: ch06
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
    DML 資料操作語言
  </h1>
  <div style="height: 4px; width: 320px; background: linear-gradient(90deg, #5eada0, #a7d9d0); border-radius: 2px; margin-bottom: 1.5rem;"></div>
  <p style="color: #4a7c7c; font-size: 1.15rem; font-style: italic;">
    「新增、修改、刪除——對資料動手術」
  </p>
  <Link to="home" style="color: #9dc4c4; font-size: 0.85rem; margin-top: 2rem; text-decoration: none; letter-spacing: 0.05em;">← 返回目錄</Link>
</div>

<!--
大家好，歡迎來到第六章：DML 資料操作語言。

我們用 DDL 蓋好了資料表，也用 DQL 學會了查詢。可是表裡的資料從哪裡來？商品改價、會員退出，資料又要怎麼跟著變？

這就是 DML 要處理的事。它有三個核心指令：INSERT 新增、UPDATE 修改、DELETE 刪除。學完這章，大家不只會用，還會知道怎麼安全地用。
-->

---
layout: default
---

# Outline

- **INSERT 新增資料** — 單筆、多筆、從其他表複製
- **UPDATE 修改資料** — 修改欄位值，使用 WHERE 精確定位
- **DELETE 刪除資料** — 刪除特定筆資料，WITH 安全刪除
- **DML 的安全習慣** — 使用 Transaction 保護資料

<!--
這一章會依序學三個指令。先用 INSERT 新增資料，包括一次多筆，以及從其他表複製。接著是 UPDATE 修改和 DELETE 刪除，這兩個如果用錯，可能一次毀掉整張表，所以我們會花時間建立安全習慣，最後學會用交易來保護資料。
-->

---

# 範例資料表

本章的 SQL 範例基於以下資料表：

```sql
CREATE TABLE products (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(200) NOT NULL,
  category   VARCHAR(100) NOT NULL,
  price      DECIMAL(10,2) NOT NULL,
  stock      INT NOT NULL DEFAULT 0,
  is_active  TINYINT(1) NOT NULL DEFAULT 1,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>ON UPDATE CURRENT_TIMESTAMP：</b>updated_at 欄位在每次這筆資料被修改時，自動更新為目前時間，不需要在 SQL 裡手動設定。
</div>

<!--
這章的範例資料表，跟上一章的商品表幾乎一樣，只多了一個 `updated_at` 欄位。

重點在它後面的 `ON UPDATE CURRENT_TIMESTAMP`。意思是，每當這筆資料被修改，`updated_at` 就會自動更新成當下的時間。

這樣我們寫 UPDATE 的時候，就不用每次都手動設定修改時間，資料庫會自動處理。執行後，每一筆商品都會記得自己最後一次被修改是什麼時候。

這種自動記錄最後更新時間的設計，在實務上非常普遍。需要追蹤修改時間的資料表，都很建議加上這個欄位。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第一部分
# INSERT — 新增資料

<!--
我們從 INSERT 開始，也就是把新的資料放進資料表。
-->

---

# INSERT 的語法結構

```sql
-- 基本語法：明確指定欄位名稱（推薦）
INSERT INTO table_name (col1, col2, col3)
VALUES (val1, val2, val3);

-- 省略欄位名稱（不推薦：欄位順序改變就會出錯）
INSERT INTO table_name
VALUES (val1, val2, val3, val4);

-- 批次新增多筆資料（一次 INSERT）
INSERT INTO table_name (col1, col2, col3)
VALUES
  (val1a, val2a, val3a),
  (val1b, val2b, val3b),
  (val1c, val2c, val3c);
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>效能提示：</b>批次 INSERT 比多次單筆 INSERT 快得多。插入 1000 筆資料，一次批次 INSERT 可能比 1000 次單筆 INSERT 快 10 倍以上。
</div>

<!--
這頁是 INSERT 的三種寫法。

第一種是推薦的寫法，在表名後面明確列出欄位名稱，再用 `VALUES` 給對應的值。

第二種省略了欄位名稱，雖然比較短，但不推薦。想像這張表現在有五個欄位，三個月後有人在中間插了一個新欄位，這行 INSERT 的值就會塞進錯的欄位，甚至直接報錯。明確寫出欄位名稱，就不會受到影響。

第三種是批次新增，一個 INSERT 後面接好幾組值，用逗號隔開。

批次的效能好很多。每次 INSERT 都要跟資料庫來回一趟，新增一千筆資料，單筆寫法要來回一千次，批次寫法只要一次。
-->

---

# INSERT — 完整範例

在 products 表中新增商品資料：

```sql
-- 新增單筆商品
INSERT INTO products (name, category, price, stock)
VALUES ('iPhone 15', '手機', 28900.00, 50);

-- 批次新增多筆商品
INSERT INTO products (name, category, price, stock, is_active)
VALUES
  ('MacBook Air M3', '電腦', 37900.00, 30, 1),
  ('iPad Pro 11"',  '平板', 26900.00, 25, 1),
  ('AirPods Pro 2', '配件',  7490.00, 100, 1);
```

執行後，`id` 欄位由 AUTO_INCREMENT 自動填入，`updated_at` 由 DEFAULT CURRENT_TIMESTAMP 自動填入。

<!--
我們實際在商品表裡新增資料。

第一段新增一支 iPhone 15，只給了名稱、分類、價格和庫存。第二段用批次寫法，一次新增三樣商品。

大家注意，我們都沒有提供 `id` 和 `updated_at`。執行後，`id` 會由 AUTO_INCREMENT 自動編號，`updated_at` 會自動填入目前時間。第一段也沒給 `is_active`，它的預設值是 1，所以商品會是上架狀態。

這裡要提醒一點，批次新增時，只要其中一筆違反約束，例如 UNIQUE 重複，整個 INSERT 就會失敗，一筆都不會寫入。遇到這種錯誤，先找出是哪一筆重複，修正後再重新執行就可以了。
-->

---

# INSERT ... SELECT — 從查詢結果插入

「INSERT ... SELECT 讓我們把一個 SELECT 的結果直接插入到另一張表。」

```sql
-- 建立一張存放舊商品的備份表
CREATE TABLE products_archive LIKE products;

-- 把下架超過一年的商品移入備份表
INSERT INTO products_archive
  SELECT * FROM products
  WHERE is_active = 0
    AND updated_at < DATE_SUB(NOW(), INTERVAL 1 YEAR);

-- 刪除原表中已備份的資料
DELETE FROM products
  WHERE is_active = 0
    AND updated_at < DATE_SUB(NOW(), INTERVAL 1 YEAR);
```

<!--
「INSERT ... SELECT 讓我們把一個 SELECT 的結果直接插入到另一張表。」

這段範例要做的是資料歸檔，把下架超過一年的商品，搬到另一張備份表。

第一步 `CREATE TABLE products_archive LIKE products`，會建立一張結構跟商品表一模一樣的空表。

第二步是關鍵。INSERT 後面不是接 VALUES，而是直接接一個 SELECT，篩出下架而且超過一年沒更新的商品，把結果整批寫進備份表。

第三步再用同樣的條件，把原表裡這些商品刪掉。執行完，舊商品就從原表搬到了備份表。

不過要注意，如果備份那步失敗了，刪除卻照樣執行，資料就不見了。所以這類操作最好用交易包起來，這個我們等一下就會學到。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第二部分
# UPDATE — 修改資料

<!--
接下來是 UPDATE。它也是最容易出大事的語法，忘了加 WHERE，整張表都會被改掉。
-->

---

# UPDATE 的語法結構

```sql
UPDATE table_name
SET
  col1 = new_value1,
  col2 = new_value2
[WHERE condition]
[ORDER BY ...]
[LIMIT n];
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
⚠️ <b>高風險：</b>WHERE 子句是選用的，但幾乎永遠都要加！沒有 WHERE 的 UPDATE 會修改整張表的所有資料。在生產環境執行 UPDATE 前，建議先用 SELECT 確認影響範圍。
</div>

<!--
這是 UPDATE 的語法結構。先寫表名，`SET` 後面列出要改哪些欄位、改成什麼值，最後用 `WHERE` 指定要改哪幾筆。

語法裡 WHERE 被放在方括號裡，代表它是選用的。可是實務上，它幾乎永遠都要加。

想像我們只想改一個商品的價格，卻忘了寫 WHERE id 等於 123，結果就會把所有商品的價格都改成同一個數字。在正式環境，這是非常嚴重的事故。

後面的 ORDER BY 和 LIMIT 也是選用的，例如只對庫存最多的前十個商品打折。不過這種用法比較少見，大多數情況，UPDATE 只需要 SET 和 WHERE。
-->

---

# UPDATE — 常用範例

```sql
-- 修改單筆資料（用主鍵精確定位）
UPDATE products
SET price = 26900.00
WHERE id = 1;

-- 修改多個欄位
UPDATE products
SET
  price     = 24900.00,
  is_active = 0
WHERE id = 1;

-- 用計算式修改（所有電腦類商品打九折）
UPDATE products
SET price = price * 0.9
WHERE category = '電腦' AND is_active = 1;
```

<!--
這頁有三個最常見的 UPDATE 情境。

第一個用 `WHERE id = 1` 精準鎖定一筆，只改價格。用主鍵當條件是最安全的，因為一定只會影響一筆。

第二個是一次改多個欄位，價格和上架狀態用逗號隔開。執行後，這個商品會被改價，同時下架。

第三個是用計算式修改，`price = price * 0.9`，意思是把原本的價格乘以零點九，也就是打九折。這裡的條件是電腦類而且上架中的商品。

像第三個這種一次改很多筆的 UPDATE，WHERE 條件一寫錯，影響範圍就很大。所以下一頁，我們來看一個安全執行 UPDATE 的習慣。
-->

---

# 使用 UPDATE 的注意事項

安全執行 UPDATE 的最佳實踐：

```sql
-- 步驟一：先用 SELECT 確認影響範圍
SELECT id, name, price
FROM products
WHERE category = '電腦' AND is_active = 1;

-- 確認結果後，步驟二：執行 UPDATE
UPDATE products
SET price = price * 0.9
WHERE category = '電腦' AND is_active = 1;

-- 步驟三：驗證結果
SELECT id, name, price
FROM products
WHERE category = '電腦' AND is_active = 1;
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>生產環境最佳實踐：</b>重要的 UPDATE 放在 Transaction 裡，執行後先確認結果，沒問題再 COMMIT。
</div>

<!--
這是一個很實用的三步驟習慣。

第一步，把 UPDATE 的 WHERE 條件原封不動複製到 SELECT，先看看會影響哪些資料，數量對不對。

第二步，確認沒問題，才執行 UPDATE。

第三步，再 SELECT 一次，確認資料真的改成我們預期的樣子。

在正式環境，還可以更進一步，把 UPDATE 放進交易裡。先 `START TRANSACTION`，執行 UPDATE，查一下結果。沒問題就 `COMMIT` 提交，發現不對就 `ROLLBACK`，整個修改都會取消。

這也是 DML 比 DDL 安全的地方。前面 DDL 那一章說過，DDL 執行就確定了，但 DML 可以放在交易裡，還有反悔的機會。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第三部分
# DELETE — 刪除資料

<!--
接下來是 DELETE。它跟 UPDATE 一樣危險，沒有 WHERE，整張表的資料都會被刪光。
-->

---

# DELETE 的語法結構

```sql
DELETE FROM table_name
[WHERE condition]
[ORDER BY ...]
[LIMIT n];
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
⚠️ <b>最高危操作：</b>WHERE 是選用的，但沒有 WHERE 等同於刪除整張表的所有資料（等同於 TRUNCATE TABLE）。永遠先用 SELECT 確認要刪除的資料範圍！
</div>

<!--
DELETE 的語法很短，`DELETE FROM` 加上表名，後面接 WHERE，也可以搭配 ORDER BY 和 LIMIT。

正因為它很短，才特別危險。只寫 `DELETE FROM products` 就按下執行，所有商品資料會立刻消失。雖然 DELETE 可以放在交易裡反悔，但很多時候，等我們發現出錯，修改早就提交了。

所以有四個習慣一定要養成。第一，永遠加上 WHERE。第二，執行前先用 SELECT 確認範圍。第三，重要的操作放在交易裡。第四，重要的資料先備份。

這些不是多餘的步驟，而是很多真實事故換來的教訓。
-->

---

# DELETE — 常用範例

```sql
-- 刪除單筆資料（用主鍵精確定位）
DELETE FROM products WHERE id = 10;

-- 刪除符合條件的多筆資料
DELETE FROM products
WHERE is_active = 0
  AND updated_at < '2023-01-01';

-- 限制刪除筆數（安全模式）
DELETE FROM products
WHERE is_active = 0
ORDER BY updated_at ASC
LIMIT 100;
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>分批刪除：</b>如果要刪除大量資料，用 LIMIT 分批刪除，避免單次刪除太多造成鎖表時間過長。
</div>

<!--
這頁有三種常見的 DELETE 寫法。

第一個用 `WHERE id = 10` 精準刪除一筆，這是最安全的寫法。

第二個是批次刪除，條件是下架中、而且在 2023 年之前就沒再更新過的商品，兩個條件用 AND 連起來，必須同時成立。

第三個是分批刪除。`LIMIT 100` 讓這次最多只刪一百筆，搭配 `ORDER BY updated_at ASC`，每次都先刪最舊的那一批。

為什麼要分批呢？一次刪除幾十萬筆資料，會把表鎖住很久，其他查詢都得排隊等。分批執行，每次只鎖一下下，對線上系統的影響就小很多。
-->

---

# DML 的安全習慣：Transaction

「Transaction（事務）讓多個 DML 操作成為一個原子單位——要麼全部成功，要麼全部失敗。」

```sql
-- 開始事務
START TRANSACTION;

-- 備份要刪除的資料
INSERT INTO products_archive
  SELECT * FROM products WHERE id = 10;

-- 確認備份成功後，刪除原資料
DELETE FROM products WHERE id = 10;

-- 確認一切正確，提交事務
COMMIT;

-- 如果發現問題，取消整個操作
-- ROLLBACK;
```

<!--
前面一直提到交易，這頁我們正式來看。「Transaction 讓多個 DML 操作成為一個原子單位，要麼全部成功，要麼全部失敗。」

就像去銀行轉帳，從 A 帳戶扣錢、在 B 帳戶加錢，這兩件事一定要一起完成。只做一半，錢就憑空消失了。

這段範例先用 `START TRANSACTION` 開始交易，接著把資料備份到 `products_archive`，再刪除原資料。兩步都成功，就用 `COMMIT` 讓修改正式生效。如果中間發現問題，就 `ROLLBACK`，所有操作都會取消。

這樣就不會出現備份失敗、資料卻已經刪掉的半完成狀態。

另外要提醒，CREATE、ALTER、DROP 這些 DDL 會自動提交目前的交易，所以交易只保護得了 DML。
-->

---

# 總結

本章學了 DML 資料操作語言的核心指令：

- **INSERT** — 新增資料，建議明確指定欄位；批次插入效能更好
- **INSERT ... SELECT** — 從查詢結果插入，適合資料備份和遷移
- **UPDATE** — 修改資料；務必加 WHERE；執行前先 SELECT 確認範圍
- **DELETE** — 刪除資料；務必加 WHERE；大量刪除用 LIMIT 分批
- **Transaction** — START TRANSACTION / COMMIT / ROLLBACK 保護關鍵操作

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
🚀 <b>安全原則：</b>UPDATE 和 DELETE 之前，先用相同 WHERE 條件執行 SELECT，確認影響範圍！
</div>

<!--
我們整理這一章。INSERT 建議明確寫出欄位，批次新增效能更好，搭配 SELECT 還能整批複製。UPDATE 和 DELETE 一定要加 WHERE，大量刪除要分批。重要的操作，就用交易保護起來。

這章最重要的，是畫面下方那條安全原則：UPDATE 和 DELETE 之前，先用相同的 WHERE 條件 SELECT 一次。

接下來，我們用兩題練習把這些操作練熟。
-->

---
layout: default
---

# 練習 1：任務說明
### 動態問卷：後台的新增、發佈與刪除

請重新執行 `sql/schema.sql` 與 `sql/seed.sql` 重置資料，再模擬管理員的操作：

**任務：**
1. 新增問卷「社團博覽會意見調查」，開始日期為今天 + 2、結束日期為今天 + 7，先不發佈
2. 批次新增兩個題目：「你會參加嗎？」（單選、必填）、「其他建議」（文字）
3. 按下「儲存並發佈」：把這份問卷的 `published` 改成 1
4. 管理員勾選了問卷 2、4、5 要刪除，但只有未發佈或尚未開始的問卷可以刪。先 SELECT 確認，再 DELETE

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>提示：</b><code>DATE_ADD(CURDATE(), INTERVAL 2 DAY)</code> 算出兩天後；<code>SET @sid = LAST_INSERT_ID();</code> 記下剛新增的 id。
</div>

<!--
這題模擬管理員在後台的三個動作，新增、發佈和批次刪除。

題目要掛在剛新增的問卷底下，可是 id 是自動產生的，要怎麼知道？畫面上的 `LAST_INSERT_ID` 就能取回它，再存到變數 `@sid` 裡。

思考一下，問卷 2 也被勾選了，但它正在進行中，不能刪。這個規則要怎麼寫進 DELETE？

我們先暫停一下，自己動手試試看。

【講師】給大家十五分鐘，提醒同學先重置資料，才會和解答的結果一致。
-->

---
layout: default
---

# 練習 1：解題提示

```sql
-- 1. 新增問卷（published 預設就是 0，也就是先不發佈）
INSERT INTO surveys
  (title, description, start_date, end_date)
VALUES ('社團博覽會意見調查', '你對博覽會有什麼想法？',
        DATE_ADD(CURDATE(), INTERVAL 2 DAY),
        DATE_ADD(CURDATE(), INTERVAL 7 DAY));

-- 2. 記下剛新增的 id，批次新增題目
SET @sid = LAST_INSERT_ID();
INSERT INTO questions
  (survey_id, title, type, required, order_index)
VALUES (@sid, '你會參加嗎？', 'SINGLE', 1, 1),
       (@sid, '其他建議',     'TEXT',   0, 2);

-- 3. 儲存並發佈
UPDATE surveys SET published = 1
WHERE id = @sid AND published = 0;
```

<!--
第一步沒有寫 `published`，因為它的預設值就是 0，正好是先不發佈。

第二步用 `LAST_INSERT_ID` 取回剛產生的 id。它只看自己這條連線，就算別人同時也在新增，也不會拿到別人的 id。

第三步的 UPDATE 多加了 `published = 0` 的條件。已經發佈過的問卷就不會被重複修改，這也是 UPDATE 一定要寫好 WHERE 的好習慣。
-->

---
layout: default
---

# 練習 1：解題提示（續）

```sql
-- 4. 先用同樣的條件 SELECT 確認範圍
SELECT id, title FROM surveys
WHERE id IN (2, 4, 5)
  AND (published = 0 OR CURDATE() < start_date);

-- 確認無誤再 DELETE
DELETE FROM surveys
WHERE id IN (2, 4, 5)
  AND (published = 0 OR CURDATE() < start_date);
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>結果：</b>只有 4（尚未開始）、5（未發佈）被刪，2（進行中）保留。它們的題目也因為 <code>ON DELETE CASCADE</code> 一起消失。
</div>

<!--
這就回答了剛才的思考題。把可以刪除的規則直接寫進 WHERE，就算問卷 2 在勾選清單裡，也不會被刪掉。

執行前先用一模一樣的條件 SELECT，確認看到的只有問卷 4 和 5，再執行 DELETE。

規則寫在 SQL 裡還有一個好處，就算有人繞過畫面直接呼叫後端，進行中的問卷一樣刪不掉。
-->

---
layout: default
---

# 練習 2：任務說明
### 送出一份作答（Transaction）

使用者按下「確認送出」時，要寫入一筆 `survey_responses`，再寫入每一題的答案 `response_answers`。這兩件事必須**同時成功或同時失敗**。

**任務：**
1. 用 Transaction 為問卷 3 新增一份作答：姓名「周小華」、手機 `0933000011`、Email `a11@example.com`、年齡 22；題目 5 選「芝麻」、題目 6 填「黑芝麻香」
2. 再用**同一個 Email** 對問卷 3 送出第二次，觀察錯誤訊息，並用 `ROLLBACK` 收尾
3. 查詢確認：問卷 3 目前有幾份作答、剛才那份有幾筆答案

<!--
第二題是使用者按下確認送出時，資料庫要做的事。作答紀錄和每一題的答案要一起寫入，所以要放進同一個交易。

第二個步驟要故意重複送出，請大家仔細看 MySQL 回報的錯誤訊息。

思考一下，如果沒有交易，寫完作答紀錄之後，寫入答案時失敗了，資料庫會留下什麼？

我們先暫停一下，自己動手試試看。

【講師】給大家十分鐘，可以提示這裡也用得到剛才的 `LAST_INSERT_ID`。
-->

---
layout: default
---

# 練習 2：解題提示

```sql
-- 1. 一次作答 = 一個 Transaction
START TRANSACTION;

INSERT INTO survey_responses
  (survey_id, name, phone, email, age)
VALUES (3, '周小華', '0933000011', 'a11@example.com', 22);

SET @rid = LAST_INSERT_ID();

INSERT INTO response_answers
  (response_id, question_id, answer_text)
VALUES (@rid, 5, '芝麻'),
       (@rid, 6, '黑芝麻香');

COMMIT;
```

<!--
`START TRANSACTION` 之後的修改，在 COMMIT 之前都還沒有正式生效。我們先寫入作答紀錄，用 `@rid` 記下它的 id，再把兩筆答案掛上去，最後一起提交。

這也回答了剛才的思考題。如果沒有交易，答案寫入失敗時，資料庫就會留下一筆殘缺的紀錄。它有作答者，卻沒有任何答案，後台看到的就是一份空白的作答。
-->

---
layout: default
---

# 練習 2：解題提示（續）

```sql
-- 2. 同一 Email 重複送出，違反 UNIQUE (survey_id, email)
START TRANSACTION;
INSERT INTO survey_responses (survey_id, name, phone, email)
VALUES (3, '周小華', '0933000011', 'a11@example.com');
-- ERROR 1062 (23000): Duplicate entry '3-a11@example.com'
--   for key 'survey_responses.uk_survey_email'
ROLLBACK;

-- 3. 確認結果
SELECT COUNT(*) AS response_count
FROM survey_responses WHERE survey_id = 3;  -- 2

SELECT COUNT(*) AS answer_count
FROM response_answers WHERE response_id = @rid;  -- 2
```

<!--
第二次送出會被唯一約束擋下來，MySQL 回傳錯誤碼 1062。我們用 ROLLBACK 取消這個交易。

程式當然可以先查有沒有填過，但兩個請求同時進來時，可能都查到沒填過。所以實務上兩者並用，程式負責給出友善的提示，資料庫約束當最後一道防線。

最後確認一下，問卷 3 有兩份作答，一份是原本的，一份是周小華的，周小華的作答有兩筆答案。
-->

---
layout: end
---

# Q & A

有任何問題嗎？

<!--
今天我們學會了用 INSERT、UPDATE、DELETE 操作資料，也學會用交易保護重要的操作。

最重要的是安全習慣：UPDATE 和 DELETE 一定加 WHERE，執行前先 SELECT 確認，重要操作放進交易，大量修改分批進行。

到這裡，增刪改查四種基本操作都學完了。下一章，我們要學 JOIN，把分散在不同資料表的資料合在一起查。我們下一章見。

【講師】開放提問，可以請同學分享自己會怎麼避免誤刪資料。
-->
