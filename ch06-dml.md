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

這也是 DML 比 DDL 安全的地方。上一章說過，DDL 執行就確定了，但 DML 可以放在交易裡，還有反悔的機會。
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
### 完整的 CRUD 操作

以下是 `students` 表（學生表），請完成四個操作：

```sql
CREATE TABLE students (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(100) NOT NULL,
  email      VARCHAR(255) NOT NULL UNIQUE,
  score      DECIMAL(5,2),
  is_active  TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**任務：**
1. 批次新增三位學生
2. 把 score < 60 的學生的 is_active 設為 0
3. 刪除 email 為 'test@example.com' 的學生（先 SELECT 確認再 DELETE）
4. 查詢目前仍在學（is_active=1）且 score >= 80 的學生，按 score 降冪排列

<!--
第一題是完整的增刪改查練習，使用畫面上這張 `students` 學生表。

任務有四個。先一次新增三位學生，再把分數低於六十分的學生設為非在學。接著刪除 email 是 `test@example.com` 的學生，記得先確認再刪除。最後查出還在學、而且分數八十分以上的學生，依分數由高到低排列。

這題結合了這一章的新增、修改、刪除，以及上一章的查詢。

我們先暫停一下，動手寫寫看。

【講師】給大家十分鐘，可以提醒第三題要先 SELECT 再 DELETE。
-->

---
layout: default
---

# 練習 1：解題提示

```sql
-- 1. 批次新增三位學生
INSERT INTO students (name, email, score)
VALUES
  ('Alice Chen', 'alice@example.com', 92.5),
  ('Bob Wang',   'bob@example.com',   75.0),
  ('Carol Lin',  'carol@example.com', 58.0);

-- 2. 把不及格學生設為非在學
UPDATE students
SET is_active = 0
WHERE score < 60 AND is_active = 1;

-- 3. 先確認再刪除
SELECT * FROM students WHERE email = 'test@example.com';
DELETE FROM students WHERE email = 'test@example.com';

-- 4. 查詢在學且高分學生
SELECT id, name, score
FROM students
WHERE is_active = 1 AND score >= 80
ORDER BY score DESC;
```

<!--
我們來看解答。

第一題是批次 INSERT，每一組值用括號包起來，組跟組之間用逗號隔開。`is_active` 和 `created_at` 都有預設值，所以不用給。

第二題的 UPDATE 用了兩個條件，分數低於六十，而且目前還在學。後面那個條件其實不加也不會錯，但加上之後，只會改到真正需要改的資料，意思也更清楚。

第三題先用 SELECT 確認這位學生真的存在，看到結果後才 DELETE，這就是我們的安全習慣。

第四題是上一章的技巧，兩個條件用 AND 連接，再用 `ORDER BY score DESC` 讓高分的排在前面。執行後就是一份高分在學學生的名單。
-->

---
layout: default
---

# 練習 2：任務說明
### 安全的大量更新

你的電商系統要進行「年終折扣活動」：

- 所有價格超過 10000 的商品打八折
- 所有「配件」類別的商品打七折

**任務：**
1. 先在 `products_backup` 備份現有商品（CREATE TABLE ... LIKE + INSERT ... SELECT）
2. 執行兩個 UPDATE（八折和七折），用 Transaction 包住
3. 用 SELECT 檢查結果：正確就 COMMIT，發現錯誤就 ROLLBACK

<!--
第二題來模擬一個年終折扣活動。價格超過一萬的商品打八折，配件類商品打七折。

任務有三步。先把商品表完整備份到 `products_backup`。再用交易包住兩個打折的 UPDATE。最後查詢結果，正確就提交，發現錯誤就取消。

思考一下，兩個 UPDATE 放在同一個交易裡，有什麼好處？

我們先暫停一下，自己寫寫看。

【講師】給大家十分鐘，可以提醒 COMMIT 和 ROLLBACK 只能二選一。
-->

---
layout: default
---

# 練習 2：解題提示

```sql
-- 1. 備份商品表
CREATE TABLE products_backup LIKE products;
INSERT INTO products_backup SELECT * FROM products;

-- 2. 用 Transaction 執行折扣更新
START TRANSACTION;

UPDATE products
SET price = price * 0.8
WHERE price > 10000;

UPDATE products
SET price = price * 0.7
WHERE category = '配件';

-- 3. 檢查結果
SELECT id, name, category, price FROM products;

COMMIT;     -- 結果正確：提交
-- ROLLBACK; -- 發現錯誤：取消兩個 UPDATE
```

<!--
我們來看解答。

第一步用 `CREATE TABLE ... LIKE` 建立一張結構相同的空表，再用 `INSERT ... SELECT` 把資料全部複製過去。這是多一層保險，萬一交易提交後才發現問題，還有備份可以參考。

第二步把兩個 UPDATE 放進同一個交易。這就回答了剛才的思考題，兩個修改會被當成一件事，不會出現有些商品打了折、有些沒有的狀況。

第三步先 SELECT 檢查價格。結果正確就 COMMIT，修改正式生效。發現打錯折，就 ROLLBACK，兩個 UPDATE 會一起取消，商品價格回到交易開始前的樣子。
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
