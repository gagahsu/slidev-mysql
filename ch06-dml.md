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
大家好，歡迎來到第六章——DML 資料操作語言！

DDL 蓋好了資料庫的結構，DQL 學會了怎麼查詢資料，現在我們要學怎麼對資料「動手術」——新增、修改和刪除。

DML（Data Manipulation Language）包含三個核心指令：INSERT、UPDATE、DELETE。

這三個指令是資料庫應用開發中使用頻率最高的操作，幾乎每一個 CRUD（Create/Read/Update/Delete）應用都離不開它們。
-->

---
layout: default
---

# Outline

- **INSERT 新增資料** — 單筆、多筆、從其他表複製
- **UPDATE 修改資料** — 修改欄位值，使用 WHERE 精確定位
- **DELETE 刪除資料** — 刪除特定筆資料，WITH 安全刪除
- **DML 的安全習慣** — 使用 Transaction 保護資料
- **INSERT ON DUPLICATE KEY UPDATE** — 存在則更新，不存在則新增

<!--
這章有五個部分。

INSERT、UPDATE、DELETE 是三個獨立的語法，我們一個一個說清楚。

特別重要的是「安全習慣」的部分——UPDATE 和 DELETE 操作不當，可能造成大規模的資料損失。我會告訴大家怎麼保護自己。

最後的 INSERT ... ON DUPLICATE KEY UPDATE 是實際開發中非常實用的進階語法。
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
這張 products 表和第五章用的一樣，但多了一個 updated_at 欄位。

ON UPDATE CURRENT_TIMESTAMP 是很實用的 MySQL 功能：每次這筆資料被 UPDATE 時，updated_at 欄位會自動更新為當前時間。這讓你不需要在每個 UPDATE 語句裡手動設定 updated_at = NOW()，資料庫幫你自動處理。

這種「自動記錄最後更新時間」的設計在實際應用中非常普遍，建議所有需要追蹤修改時間的資料表都加上這個欄位。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第一部分
# INSERT — 新增資料

<!--
進入第一部分，學習 INSERT 語法。

INSERT 就是把新的資料放進資料表裡。
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
INSERT 的語法建議永遠明確指定欄位名稱。

為什麼？想像你的表今天有 5 個欄位，你用省略欄位名稱的方式寫了 INSERT。三個月後，DBA 在第 3 個欄位和第 4 個欄位之間新增了一個欄位，你的 INSERT 語句就會把值插入錯誤的欄位，甚至報錯。

如果你有明確指定欄位名稱，新增欄位不會影響現有的 INSERT 語句。

批次插入的效能優勢：每次 INSERT 都有網路往返時間和事務開銷。1000 次單筆 INSERT 有 1000 次往返；批次 INSERT 只有 1 次往返。
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
看這個範例，我們只提供了 name、category、price、stock（和 is_active），沒有提供 id 和 updated_at。

id 是 AUTO_INCREMENT，MySQL 會自動給下一個可用的整數（例如 1、2、3...）。
updated_at 有 DEFAULT CURRENT_TIMESTAMP，MySQL 會自動填入目前時間。

is_active 有 DEFAULT 1，所以第一個 INSERT 省略了 is_active，MySQL 會自動填入 1（上架狀態）。

⚠️ 批次插入時，如果其中一筆資料違反約束（例如 UNIQUE 衝突），整個 INSERT 語句都會失敗，一筆都不會插入。如果需要「成功幾筆算幾筆」的行為，可以使用 INSERT IGNORE。
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
INSERT ... SELECT 是一個很實用的語法，讓我們能夠根據查詢條件，把資料從一張表複製到另一張表。

在這個例子中，我們把下架超過一年的商品備份到 products_archive，然後從原表刪除，達到「歸檔」的效果。

CREATE TABLE ... LIKE 建立一張和 products 結構完全相同的空表，包含所有欄位定義和約束，但沒有資料。

⚠️ 在生產環境執行這樣的操作時，建議先在 Transaction 裡做，確認備份成功後再 COMMIT 刪除操作。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第二部分
# UPDATE — 修改資料

<!--
進入第二部分：UPDATE。

UPDATE 是修改現有資料的語法。它也是最容易犯「災難性錯誤」的語法——一個不小心忘記加 WHERE，可能修改整張表的所有資料。

我們要特別學習怎麼安全地使用 UPDATE。
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
UPDATE 語法本身不複雜，但「沒有 WHERE」是一個非常危險的陷阱。

想像一下：你想更新某個商品的價格，但忘記加 WHERE id = 123，就變成了把所有商品的價格都改成新的值。這在生產環境是非常嚴重的事故。

ORDER BY 和 LIMIT 在 UPDATE 中也是可選的：
UPDATE products SET price = price * 0.9 ORDER BY stock DESC LIMIT 10
這會對庫存最多的前 10 個商品打九折。

但這種用法不太常見，大多數情況下 UPDATE 只需要 SET 和 WHERE。
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
看這三個範例，涵蓋了 UPDATE 最常用的三種情境。

第一個：用 WHERE id = 1 精確定位要修改的那一筆，只修改 price。主鍵是最安全的 WHERE 條件。

第二個：同時修改多個欄位，用逗號分隔。注意：最後一個 SET 項目後面沒有逗號。

第三個：用計算式修改，price * 0.9 代表九折。這種批次修改要特別小心 WHERE 條件是否正確。

⚠️ 執行批次 UPDATE 前，先用相同的 WHERE 條件做 SELECT，確認影響的範圍是你預期的，再執行 UPDATE。例如：SELECT * FROM products WHERE category = '電腦' AND is_active = 1 看看有幾筆，確認無誤後再執行 UPDATE。
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
這個「三步驟法」是我在工作中養成的習慣，建議大家也這樣做：

步驟一：把 UPDATE 的 WHERE 條件複製到 SELECT，確認影響的資料是你預期的。
步驟二：執行 UPDATE。
步驟三：再次 SELECT，確認資料已經正確修改。

在生產環境，可以更進一步：把 UPDATE 放在 Transaction 裡：

START TRANSACTION;
UPDATE products SET price = price * 0.9 WHERE category = '電腦';
SELECT * FROM products WHERE category = '電腦';  -- 確認結果
COMMIT;  -- 確認無誤後提交；或 ROLLBACK 取消

如果 SELECT 確認後發現修改有問題，可以 ROLLBACK 取消整個操作。這是 DML 比 DDL 安全的地方——DML 支援 Transaction，DDL 不行。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第三部分
# DELETE — 刪除資料

<!--
進入第三部分：DELETE。

DELETE 和 UPDATE 一樣危險——沒有 WHERE 會刪掉整張表的所有資料。我們同樣需要學習安全使用的方法。
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
DELETE 是 SQL 中最危險的操作之一。

"DELETE FROM products;" 這五個字，如果在生產環境誤執行，會立刻刪掉所有商品資料。而且 DELETE 雖然可以放在 Transaction 裡 ROLLBACK，但很多時候在你意識到出錯之前，操作就已經 COMMIT 了。

因此：
1. 永遠加 WHERE 條件
2. 執行前先 SELECT 確認
3. 放在 Transaction 裡
4. 重要資料先備份

這些不是多餘的步驟，都是真實事故中學到的血淚教訓。
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
第一個範例是最安全的：用 WHERE id = 10 精確定位，確保只刪一筆。

第二個是批次刪除：刪除下架且超過一年沒更新的商品。注意兩個條件都要同時成立（AND）。

第三個是「分批刪除」的做法：LIMIT 100 確保這次最多只刪 100 筆。如果要刪除的資料很多，可以用這個方式重複執行，避免一次刪太多導致鎖表時間過長，影響其他查詢。

分批刪除的 LIMIT 和 ORDER BY 通常搭配使用：ORDER BY updated_at ASC 確保每次都刪除最舊的那批資料。
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
Transaction 是 DML 操作的安全網。

ACID 原則（Atomicity、Consistency、Isolation、Durability）是資料庫事務的核心。其中 Atomicity（原子性）確保了：如果事務中有任何操作失敗，整個事務都會回滾，不會出現「備份成功但原資料沒有刪除」或「原資料刪除了但備份失敗」的半完成狀態。

在這個範例中：
1. 先把資料備份到 products_archive
2. 再刪除原資料
3. 如果兩個操作都成功，COMMIT 讓修改永久生效
4. 如果任何一步失敗（或你發現結果不對），ROLLBACK 讓所有操作都取消

⚠️ 注意：DDL 語句（CREATE、ALTER、DROP）會隱式提交當前事務，不能被 ROLLBACK。Transaction 只對 DML 有效。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第四部分
# 進階 INSERT 技巧

<!--
最後一個部分，我們學一個非常實用的進階語法：INSERT ... ON DUPLICATE KEY UPDATE。

這個語法解決了「存在就更新，不存在就新增」的常見需求。
-->

---

# INSERT IGNORE — 忽略重複

「INSERT IGNORE 讓重複插入的資料靜默失敗，不報錯。」

```sql
-- 一般 INSERT，若 sku 重複會報錯
INSERT INTO products (name, sku, price)
VALUES ('iPhone 15', 'IPH15', 28900.00);

-- INSERT IGNORE，若 sku 重複則忽略這筆，繼續執行
INSERT IGNORE INTO products (name, sku, price)
VALUES
  ('iPhone 15', 'IPH15', 28900.00),
  ('iPhone 15 Pro', 'IPH15P', 39900.00);
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>適用場景：</b>批次匯入資料時，希望重複的資料直接跳過，不影響其他資料的插入。
</div>

<!--
INSERT IGNORE 讓你在批次插入時，遇到重複（違反 UNIQUE 約束）的資料就靜默跳過，不報錯，繼續插入下一筆。

這在資料匯入場景很常用：例如你每天從外部系統同步商品資料，有些商品已經存在，有些是新的。用 INSERT IGNORE 可以讓新商品順利插入，已存在的商品靜默跳過。

但要注意：INSERT IGNORE 不只忽略 DUPLICATE 錯誤，它會忽略所有錯誤（包括資料類型不符、NOT NULL 欄位為空等）。這有時會讓你遺漏重要的錯誤。在需要嚴格驗證的場景，要謹慎使用。
-->

---

# INSERT ... ON DUPLICATE KEY UPDATE

「存在就更新（UPSERT），不存在就新增——解決了一個非常常見的業務需求。」

```sql
-- 新增或更新商品庫存
INSERT INTO products (sku, name, category, price, stock)
VALUES ('IPH15', 'iPhone 15', '手機', 28900.00, 10)
ON DUPLICATE KEY UPDATE
  stock = stock + VALUES(stock),
  price = VALUES(price);
```

- 若 sku = 'IPH15' 不存在：插入新商品，stock = 10
- 若 sku = 'IPH15' 已存在：stock 加上 10，price 更新為新價格

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>觸發條件：</b>ON DUPLICATE KEY UPDATE 在 PRIMARY KEY 或 UNIQUE KEY 衝突時觸發更新。
</div>

<!--
ON DUPLICATE KEY UPDATE 是 MySQL 特有的語法，解決了「Upsert」（insert or update）的需求。

常見的應用場景：庫存系統的補貨操作。每次進貨時，如果商品已存在就加庫存，如果是新商品就新增。

VALUES(stock) 在 ON DUPLICATE KEY UPDATE 中代表「你試圖插入的那個值」，也就是 10。所以 stock = stock + VALUES(stock) 的意思是：原本的庫存加上新進貨的 10 個。

⚠️ MySQL 8.0.20 之後，VALUES() 函式在 ON DUPLICATE KEY UPDATE 中已被標記為廢棄（deprecated），建議改用別名：
INSERT INTO ... VALUES (...) AS new ON DUPLICATE KEY UPDATE stock = stock + new.stock;
這是 MySQL 8.x 的新寫法，更清晰也更符合標準。
-->

---

# 總結

本章學了 DML 資料操作語言的核心指令：

- **INSERT** — 新增資料，建議明確指定欄位；批次插入效能更好
- **INSERT ... SELECT** — 從查詢結果插入，適合資料備份和遷移
- **UPDATE** — 修改資料；務必加 WHERE；執行前先 SELECT 確認範圍
- **DELETE** — 刪除資料；務必加 WHERE；大量刪除用 LIMIT 分批
- **Transaction** — START TRANSACTION / COMMIT / ROLLBACK 保護關鍵操作
- **INSERT IGNORE** — 重複時靜默跳過
- **ON DUPLICATE KEY UPDATE** — 存在更新，不存在新增（UPSERT）

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
🚀 <b>安全原則：</b>UPDATE 和 DELETE 之前，先用相同 WHERE 條件執行 SELECT，確認影響範圍！
</div>

<!--
學完這章，大家已經能夠對資料庫的資料進行完整的 CRUD 操作了。

最重要的安全習慣：
1. UPDATE 和 DELETE 必須加 WHERE（幾乎沒有例外）
2. 執行前先 SELECT 確認影響範圍
3. 重要操作放在 Transaction 裡
4. 大量操作分批進行，避免鎖表

這些習慣不是過度謹慎，而是在真實事故中學到的教訓。養成這些習慣，能保護你和你的資料庫。

做兩道練習，把今天的內容鞏固一下！
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
這題綜合了這一章和前一章的所有內容：INSERT（批次）、UPDATE（帶 WHERE）、DELETE（帶安全確認）、SELECT（帶 WHERE 和 ORDER BY）。

提示三：刪除前先用 SELECT email FROM students WHERE email = 'test@example.com' 確認這個 email 存在。

提示四：這道 SELECT 結合了前一章學的 WHERE 多條件篩選和 ORDER BY。
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
解答分析：

第一題：批次 INSERT，同時插入三筆。注意每組值用括號包住，組之間用逗號分隔。

第二題：UPDATE 加了兩個 WHERE 條件：score < 60 AND is_active = 1。為什麼要加 is_active = 1？因為我們不想重複修改已經是 0 的資料（雖然重複修改不會有錯，但有這個條件讓邏輯更清晰）。

第三題：先 SELECT 確認，看到結果後再 DELETE。這是安全習慣。

第四題：兩個 WHERE 條件用 AND 連接，ORDER BY score DESC 讓高分的排在前面。
-->

---
layout: default
---

# 練習 2：任務說明
### 安全的大量更新

你的電商系統要進行「年終折扣活動」：

- 所有價格超過 10000 的商品打八折
- 所有「配件」類別的商品打七折
- 活動結束後，再把所有商品的價格恢復原始價格

**任務：**
1. 先在 `products_backup` 備份現有商品（CREATE TABLE ... LIKE + INSERT ... SELECT）
2. 執行兩個 UPDATE（八折和七折），用 Transaction 包住
3. 從備份表恢復原始價格的 SQL（提示：用 UPDATE JOIN）

<!--
這題考驗大家的 Transaction 使用和 INSERT ... SELECT 的應用。

提示：UPDATE products p JOIN products_backup b ON p.id = b.id SET p.price = b.price；這是 UPDATE JOIN 語法，從另一張表取值來更新。

思考：如果兩個 UPDATE 語句都放在同一個 Transaction 裡，有什麼好處？
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

-- 確認結果
SELECT id, name, category, price FROM products LIMIT 20;

COMMIT;  -- 確認無誤後提交

-- 3. 從備份表恢復原始價格
UPDATE products p
JOIN products_backup b ON p.id = b.id
SET p.price = b.price;
```

<!--
解答分析：

步驟一：CREATE TABLE ... LIKE 建立結構相同的空表，INSERT ... SELECT 把現有資料全部複製過去。

步驟二：兩個 UPDATE 放在同一個 Transaction 裡。這確保了：如果第二個 UPDATE 失敗，第一個 UPDATE 也會回滾，不會出現「部分商品打了折扣、部分沒有」的不一致狀態。

步驟三：UPDATE JOIN 語法是 MySQL 特有的（標準 SQL 不支援）。它讓我們能夠用一個 SELECT 的結果來更新另一張表。這裡用備份表的原始 price 更新現有表的 price。

⚠️ 在刪除備份表之前，確認恢復操作已經成功。備份表在確認無誤後再 DROP TABLE products_backup。
-->

---
layout: end
---

# Q & A

有任何問題嗎？

<!--
現在開放 Q&A 時間。

大家對 DML 有沒有什麼疑問？

特別提醒幾個最重要的安全習慣：
1. UPDATE 和 DELETE 一定要加 WHERE
2. 執行前先 SELECT 確認範圍
3. 重要操作放在 Transaction 裡
4. 大量修改分批執行

這六章——設計原則、正規化、關聯設計、DDL、DQL、DML——構成了 MySQL 最重要的基礎知識。恭喜大家完成了這個系列的基礎課程！
-->
