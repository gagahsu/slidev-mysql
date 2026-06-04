---
theme: penguin
class: text-center
highlighter: shiki
lineNumbers: true
drawings:
  persist: false
transition: slide-left
title: DDL 資料定義語言
routeAlias: ch04
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
    DDL 資料定義語言
  </h1>
  <div style="height: 4px; width: 320px; background: linear-gradient(90deg, #5eada0, #a7d9d0); border-radius: 2px; margin-bottom: 1.5rem;"></div>
  <p style="color: #4a7c7c; font-size: 1.15rem; font-style: italic;">
    「先蓋好房子，才能擺家具」
  </p>
  <Link to="home" style="color: #9dc4c4; font-size: 0.85rem; margin-top: 2rem; text-decoration: none; letter-spacing: 0.05em;">← 返回目錄</Link>
</div>

<!--
大家好，歡迎來到第四章——DDL 資料定義語言！

前三章我們學了資料庫設計的理論：設計原則、正規化、關聯設計。現在終於要動手了！

DDL（Data Definition Language，資料定義語言）就是用來「建立和管理資料庫結構」的語法。我們會學到怎麼建立資料庫、資料表、索引，以及如何修改和刪除它們。

這就像是先蓋好房子的骨架，之後才能擺進家具（資料）。
-->

---
layout: default
---

# Outline

- **什麼是 DDL？** — SQL 語言的分類與 DDL 的定位
- **CREATE 建立結構** — CREATE DATABASE、CREATE TABLE、條件約束
- **ALTER 修改結構** — ALTER TABLE 新增、修改、刪除欄位
- **DROP 與 TRUNCATE** — 刪除表格、清空資料的差異
- **練習題** — 動手建立一個完整的資料庫結構

<!--
這章的結構很直觀：建立 → 修改 → 刪除。

我們先說 SQL 語言的分類，讓大家了解 DDL 在整個 SQL 體系中的位置。

然後從最基礎的 CREATE TABLE 開始，加入各種條件約束。

接著學 ALTER TABLE，這是實際工作中修改已存在表結構時最常用的語法。

最後講 DROP 和 TRUNCATE 的差異，這兩個很容易搞混。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第一部分
# 什麼是 DDL？

<!--
進入第一部分，我們先說清楚 SQL 語言的分類，以及 DDL 在其中的位置。

這個分類很重要，後面幾章我們還會學 DQL 和 DML，大家要能區分它們的用途。
-->

---

# SQL 語言的分類

SQL 按照用途分成四大類：

| 分類 | 英文全名 | 主要指令 | 用途 |
| --- | --- | --- | --- |
| **DDL** | Data Definition Language | CREATE, ALTER, DROP, TRUNCATE | 定義和管理資料庫結構 |
| **DQL** | Data Query Language | SELECT | 查詢資料 |
| **DML** | Data Manipulation Language | INSERT, UPDATE, DELETE | 操作資料（新增、修改、刪除）|
| **DCL** | Data Control Language | GRANT, REVOKE | 控制存取權限 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>這章的重點：</b>DDL 操作的是「結構」，不是資料本身。CREATE TABLE 建立的是欄位定義，不是資料內容。
</div>

<!--
很多人剛開始學 SQL 時，會把這四類混在一起。讓我用一個比喻說明：

DDL 就像是「建築師」的工作——設計和建造房子的結構（幾個房間、每個房間的用途）。
DQL 就像是「訪客」——在房子裡找東西（查詢資料）。
DML 就像是「居住者」——搬進家具、移動或移除家具（新增、修改、刪除資料）。
DCL 就像是「門禁管理員」——決定誰能進入哪個房間（權限控制）。

今天這章我們專注在 DDL：如何建立、修改、刪除資料庫的結構。
-->

---

# 什麼是 DDL？

「DDL（Data Definition Language）是用來定義資料庫結構的語法，包括建立、修改和刪除資料庫、資料表、索引等物件。」

| DDL 指令 | 用途 |
| --- | --- |
| `CREATE` | 建立資料庫、資料表、索引、視圖等 |
| `ALTER` | 修改已存在的資料表結構 |
| `DROP` | 刪除資料庫或資料表（連同資料）|
| `TRUNCATE` | 清空資料表的所有資料（保留結構）|
| `RENAME` | 重新命名資料表或欄位 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
⚠️ <b>重要特性：</b>DDL 指令在 MySQL 中通常是自動提交（Auto-Commit），執行後無法用 ROLLBACK 復原。操作前要格外謹慎！
</div>

<!--
DDL 是資料庫工程師最常用的語法之一。每次要新增功能、修改業務邏輯，通常都需要先調整資料庫結構。

特別要注意的是：DDL 指令在 MySQL 中是自動提交的。這和 DML 不同——DML 的操作可以放在 Transaction 裡，不滿意就 ROLLBACK。但 DDL 執行後就確定了，無法撤銷。

所以在執行 DROP TABLE 或 ALTER TABLE 這類操作前，一定要確認是否已經備份。

這是一個很重要的觀念，大家要記住。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第二部分
# CREATE — 建立結構

<!--
進入第二部分，我們來學 CREATE 指令。

CREATE 是 DDL 中最常用的指令，我們從建立資料庫開始，再說建立資料表和條件約束。
-->

---

# CREATE DATABASE

「在開始建立資料表之前，我們需要先建立一個資料庫。」

```sql
-- 建立資料庫
CREATE DATABASE shop;

-- 建立時指定字元集（推薦）
CREATE DATABASE shop
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- 若已存在則不報錯
CREATE DATABASE IF NOT EXISTS shop
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- 切換到使用這個資料庫
USE shop;
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>MySQL 8.x：</b>預設字元集已是 utf8mb4，但建立時明確指定是好習慣，確保在所有環境下一致。
</div>

<!--
建立資料庫是所有操作的起點。

COLLATE utf8mb4_unicode_ci 指定了排序規則。unicode_ci 代表 Unicode Case Insensitive，表示排序時不區分大小寫（a 和 A 視為相同）。

IF NOT EXISTS 是很實用的選項——在腳本裡寫建立資料庫的語句時，加上這個選項就不用擔心資料庫已存在而報錯。這在部署腳本裡很常用。

USE shop 切換到這個資料庫。之後所有的操作都在這個資料庫裡進行，直到你切換到另一個資料庫或關閉連線。
-->

---

# CREATE TABLE 語法結構

```sql
CREATE TABLE [IF NOT EXISTS] table_name (
  column1 datatype [constraints],
  column2 datatype [constraints],
  ...
  [table_constraints]
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>必要欄位：</b>ENGINE=InnoDB 支援外鍵約束和事務；DEFAULT CHARSET=utf8mb4 支援中文和 emoji。
</div>

---

# CREATE TABLE — 完整範例

建立一張包含各種約束的 `products` 表：

```sql
CREATE TABLE products (
  id           INT AUTO_INCREMENT,
  name         VARCHAR(200)   NOT NULL,
  sku          VARCHAR(50)    NOT NULL UNIQUE,
  price        DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
  stock        INT            NOT NULL DEFAULT 0,
  category     VARCHAR(100),
  is_available TINYINT(1)     NOT NULL DEFAULT 1,
  created_at   DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

<!--
這是一個完整的 CREATE TABLE 範例，涵蓋了最常用的各種約束。

AUTO_INCREMENT：主鍵自動遞增，每次 INSERT 後 MySQL 自動給下一個可用的整數。

NOT NULL：這個欄位不能是 NULL，插入資料時必須提供值（除非有 DEFAULT）。

UNIQUE：sku 是商品的 SKU 碼，每個商品的 SKU 必須唯一。UNIQUE 和 PRIMARY KEY 的差別是：PRIMARY KEY 不能是 NULL，但 UNIQUE 可以（有多個 NULL 也不違反 UNIQUE 約束）。

DEFAULT 0.00：如果插入時沒有提供 price 的值，預設是 0.00。

DEFAULT CURRENT_TIMESTAMP：建立時自動填入目前時間。

⚠️ 注意：DECIMAL(10,2) 代表總共 10 位數，其中 2 位是小數。最大值是 99,999,999.99。金額一定用 DECIMAL，不要用 FLOAT。
-->

---

# 條件約束（Constraints）

| 約束 | 語法 | 說明 |
| --- | --- | --- |
| `NOT NULL` | `col VARCHAR(100) NOT NULL` | 欄位不能是 NULL |
| `UNIQUE` | `col VARCHAR(50) UNIQUE` | 欄位值在全表唯一 |
| `DEFAULT` | `col INT DEFAULT 0` | 未提供值時的預設值 |
| `CHECK` | `CHECK (price > 0)` | 自訂驗證條件（MySQL 8.0.16+）|
| `PRIMARY KEY` | `PRIMARY KEY (id)` | 主鍵，唯一且非空 |
| `FOREIGN KEY` | `FOREIGN KEY (x) REFERENCES t(id)` | 外鍵，確保參照完整性 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
⚠️ <b>MySQL 8.x 新功能：</b>CHECK 約束在 MySQL 8.0.16 之前的版本雖然語法不報錯，但完全不起作用。8.0.16+ 才正式支援。
</div>

<!--
條件約束是資料庫的「護欄」，確保資料的合法性。

NOT NULL 是最常用的約束，確保重要欄位不會有遺漏值。

UNIQUE 確保值不重複，但和 PRIMARY KEY 不同的是，UNIQUE 欄位允許 NULL（而且多個 NULL 不算重複）。

CHECK 約束是 MySQL 8.0.16 後才正式支援的功能。在此之前，語法雖然不報錯，但 MySQL 根本不檢查條件。如果你在使用舊版 MySQL，要特別注意這個陷阱。

DEFAULT CURRENT_TIMESTAMP 是很實用的設定，讓 created_at 欄位在插入時自動填入目前時間，不需要在應用程式層面處理。
-->

---

# CREATE INDEX 建立索引

索引讓查詢更快，但會增加寫入時的成本：

```sql
-- 建立一般索引
CREATE INDEX idx_category ON products (category);

-- 建立唯一索引（等同於 UNIQUE 約束）
CREATE UNIQUE INDEX idx_sku ON products (sku);

-- 建立複合索引（多欄位）
CREATE INDEX idx_category_price ON products (category, price);

-- 刪除索引
DROP INDEX idx_category ON products;
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>索引的取捨：</b>索引加速 SELECT 查詢，但會讓 INSERT / UPDATE / DELETE 變慢（需要維護索引）。不要在所有欄位都加索引。
</div>

<!--
索引就像書本的目錄。有了目錄，你可以快速找到想看的頁面；但多一份目錄，每次修改書的內容時也要更新目錄。

什麼欄位適合加索引？
1. 常常出現在 WHERE 條件裡的欄位
2. 常常用於 JOIN 的外鍵欄位
3. 常常用於 ORDER BY 的欄位

什麼欄位不適合加索引？
1. 值的種類很少的欄位（例如 is_active，只有 0 和 1，加索引沒什麼意義）
2. 很少被查詢的欄位

⚠️ MySQL 在建立 PRIMARY KEY 和 UNIQUE 約束時會自動建立索引，不需要手動再加。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第三部分
# ALTER — 修改結構

<!--
進入第三部分，學習 ALTER TABLE。

ALTER TABLE 是實際工作中修改資料庫結構最常用的語法。系統上線後，需求總是會變化，資料表的結構也需要跟著調整。
-->

---

# ALTER TABLE 語法結構

ALTER TABLE 可以對已存在的資料表做各種修改：

| 操作 | 語法 |
| --- | --- |
| 新增欄位 | `ALTER TABLE t ADD COLUMN col datatype` |
| 修改欄位型別 | `ALTER TABLE t MODIFY COLUMN col new_type` |
| 重新命名欄位 | `ALTER TABLE t RENAME COLUMN old TO new` |
| 刪除欄位 | `ALTER TABLE t DROP COLUMN col` |
| 新增約束 | `ALTER TABLE t ADD CONSTRAINT ...` |
| 刪除約束 | `ALTER TABLE t DROP INDEX name` |
| 重新命名表 | `ALTER TABLE t RENAME TO new_name` |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
⚠️ <b>注意：</b>ALTER TABLE 在大型資料表上可能鎖表，執行時間很長。生產環境執行前要評估影響。
</div>

<!--
ALTER TABLE 就像是在不搬走現有家具的情況下，改建房子的格局。

最常用的操作是新增欄位（ADD COLUMN）和修改欄位型別（MODIFY COLUMN）。

特別要注意的是：ALTER TABLE 在大型資料表上執行時，MySQL 可能需要重建整張表，這會鎖定表格很長一段時間，讓其他查詢都等待。在生產環境執行前，一定要在離峰時段或使用 pt-online-schema-change 等工具來處理。

RENAME COLUMN 是 MySQL 8.0 新增的語法。在舊版本，你必須用 CHANGE COLUMN old_name new_name datatype，不只改名字還要重新指定型別，很容易出錯。
-->

---

# ALTER TABLE — 範例

對 `products` 表進行各種修改：

```sql
-- 新增一個描述欄位
ALTER TABLE products
  ADD COLUMN description TEXT;

-- 修改 name 欄位長度
ALTER TABLE products
  MODIFY COLUMN name VARCHAR(500) NOT NULL;

-- 重新命名欄位（MySQL 8.0+）
ALTER TABLE products
  RENAME COLUMN is_available TO is_active;

-- 刪除一個欄位
ALTER TABLE products
  DROP COLUMN category;

-- 一次做多個修改
ALTER TABLE products
  ADD COLUMN weight DECIMAL(8,3),
  ADD COLUMN brand VARCHAR(100),
  ADD INDEX idx_brand (brand);
```

<!--
這幾個範例涵蓋了 ALTER TABLE 最常用的操作。

重點是最後一個範例：一次 ALTER TABLE 可以做多個操作，用逗號分隔。這樣做的好處是：MySQL 只需要重建一次表格，而不是每個操作都重建一次。在大型表上，這個差別可能讓修改時間從 3 分鐘縮短到 1 分鐘。

⚠️ 刪除欄位要特別小心——DROP COLUMN 會讓那個欄位的所有資料永久消失，沒有辦法透過 SQL 復原。執行前務必確認這個欄位確實不需要了，或者已經備份了資料。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第四部分
# DROP vs TRUNCATE

<!--
最後一個部分，我們來說 DROP 和 TRUNCATE。

這兩個指令都跟「刪除」有關，但差別很大，是初學者最容易混淆的地方。
-->

---

# DROP TABLE — 刪除整張表

「DROP TABLE 就像是把整棟房子拆掉，連地基都沒了。」

```sql
-- 刪除資料表（若不存在會報錯）
DROP TABLE products;

-- 安全刪除（若不存在不報錯）
DROP TABLE IF EXISTS products;

-- 刪除多張表
DROP TABLE IF EXISTS order_items, orders;

-- 刪除資料庫
DROP DATABASE IF EXISTS shop;
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
⚠️ <b>高風險操作：</b>DROP TABLE 會刪除表格結構和所有資料，無法復原。如果有其他表格的外鍵參照這張表，也會報錯。生產環境執行前務必備份！
</div>

<!--
DROP TABLE 是最徹底的刪除操作——它刪除了資料表的定義（欄位結構）以及所有資料。

IF NOT EXISTS 是 CREATE TABLE 的選項，這裡對應的是 IF EXISTS：如果表格存在就刪除，如果不存在也不報錯。在腳本裡很常用。

刪除有外鍵參照的表時，MySQL 會報錯。例如你想刪除 customers 表，但 orders 表的 customer_id 外鍵參照了 customers，MySQL 不允許你先刪除 customers。正確的順序是先刪 orders，再刪 customers——或者先 DROP FOREIGN KEY，再 DROP TABLE。

⚠️ 這是生產環境中最危險的操作之一。請永遠在執行前確認：你刪的是不是你以為的那張表，資料是否已備份。
-->

---

# TRUNCATE TABLE — 清空資料

「TRUNCATE TABLE 就像是把房子裡的所有家具搬空，但房子本身還在。」

```sql
-- 清空資料表的所有資料（保留表結構）
TRUNCATE TABLE products;

-- 等同效果，但效率不如 TRUNCATE
DELETE FROM products;
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>TRUNCATE 的特性：</b>速度比 DELETE 快（直接重建表，不記錄每一行的刪除）；AUTO_INCREMENT 計數器會重置為 1；無法用 WHERE 條件篩選。
</div>

<!--
TRUNCATE TABLE 是清空整張表最快的方式。它的內部實作是直接刪除並重建資料表，速度遠比逐行 DELETE 快。

但要注意幾個限制：
1. TRUNCATE 不能用 WHERE 條件——它只能清空整張表，不能只刪部分資料
2. TRUNCATE 會重置 AUTO_INCREMENT 計數器，下一筆資料的 ID 會從 1 開始
3. TRUNCATE 在 MySQL 中是 DDL，不是 DML，所以無法在 Transaction 裡 ROLLBACK

如果你只想刪除部分資料，用 DELETE WHERE；如果要清空整張表且不需要回滾，用 TRUNCATE。
-->

---

# DROP vs TRUNCATE vs DELETE 比較

| 面向 | DROP TABLE | TRUNCATE TABLE | DELETE FROM |
| --- | --- | --- | --- |
| 刪除結構 | ✅ 連結構一起刪 | ❌ 保留結構 | ❌ 保留結構 |
| 刪除資料 | ✅ 全部刪除 | ✅ 全部刪除 | ✅ 可篩選 |
| WHERE 條件 | ❌ | ❌ | ✅ |
| AUTO_INCREMENT 重置 | ✅ | ✅ | ❌ |
| 可 ROLLBACK | ❌ DDL，自動提交 | ❌ DDL，自動提交 | ✅ DML，可回滾 |
| 速度 | 最快 | 快 | 慢（逐行刪除）|

<!--
這是三個刪除操作的完整比較。

記憶口訣：
- DROP：拆掉整棟房子（結構 + 資料都沒了）
- TRUNCATE：搬空所有家具（資料沒了，結構還在，AUTO_INCREMENT 重置）
- DELETE：移走特定家具（可以選擇刪哪些，可以 ROLLBACK）

最危險的是 DROP，因為連結構都沒了，要重建就必須重新 CREATE TABLE。

最安全的是 DELETE，因為可以加 WHERE 條件，而且放在 Transaction 裡可以 ROLLBACK。

TRUNCATE 介於兩者之間：比 DROP 安全（結構還在），比 DELETE 快，但沒辦法 ROLLBACK。
-->

---

# 總結

本章學了 DDL 資料定義語言的核心指令：

- **SQL 分類** — DDL（定義結構）/ DQL（查詢）/ DML（操作資料）/ DCL（權限控制）
- **CREATE DATABASE** — 建立資料庫，指定 utf8mb4 字元集
- **CREATE TABLE** — 定義欄位型別與條件約束（NOT NULL、UNIQUE、DEFAULT、CHECK）
- **CREATE INDEX** — 加速查詢，但增加寫入成本
- **ALTER TABLE** — 新增、修改、刪除欄位，可一次做多個修改
- **DROP TABLE** — 刪除整張表（含結構），不可復原
- **TRUNCATE TABLE** — 清空資料保留結構，速度快，AUTO_INCREMENT 重置

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
🚀 <b>下一章：</b>我們將學習 DQL——使用 SELECT 語法從資料表中查詢各種資料！
</div>

<!--
學完這章，大家已經能夠用 SQL 建立完整的資料庫結構了。

特別要記住 DDL 的自動提交特性：DROP TABLE 和 TRUNCATE TABLE 都無法 ROLLBACK，執行前一定要確認！

下一章 DQL 會用到今天建立的資料表，進行各種查詢操作。大家先對今天的內容做兩道練習！
-->

---
layout: default
---

# 練習 1：任務說明
### 建立圖書館資料庫

請建立一個圖書館管理系統的資料庫結構，包含：

- `books`（書籍）：書名（必填）、ISBN（唯一）、出版年份、頁數、價格（DECIMAL）
- `authors`（作者）：姓名（必填）、國籍
- `members`（會員）：姓名（必填）、email（唯一）、加入日期（預設今天）
- `borrowings`（借閱記錄）：哪個會員借了哪本書、借閱日期、歸還日期

**任務：** 用 CREATE TABLE 寫出所有表格，設定適當的主鍵、外鍵和條件約束。

<!--
這題考驗大家能否把前三章的設計原則和今天的 CREATE TABLE 語法結合起來。

提示一：books 和 authors 是一對多關係（一個作者可以寫多本書），外鍵要放在哪裡？

提示二：borrowings 是多對多的中介表（一個會員可以借多本書，一本書可以被多個會員借過）。

提示三：歸還日期不是必填的（書還沒還就沒有歸還日期），所以允許 NULL。
-->

---
layout: default
---

# 練習 1：解題提示

```sql
CREATE TABLE authors (id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL, nationality VARCHAR(50)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE books (id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(300) NOT NULL, isbn VARCHAR(20) UNIQUE,
  publish_year YEAR, pages INT, price DECIMAL(8,2),
  author_id INT NOT NULL,
  FOREIGN KEY (author_id) REFERENCES authors(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE members (id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL, email VARCHAR(255) NOT NULL UNIQUE,
  joined_date DATE NOT NULL DEFAULT (CURRENT_DATE)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE borrowings (id INT AUTO_INCREMENT PRIMARY KEY,
  member_id INT NOT NULL, book_id INT NOT NULL,
  borrow_date DATE NOT NULL, return_date DATE,
  FOREIGN KEY (member_id) REFERENCES members(id),
  FOREIGN KEY (book_id) REFERENCES books(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

<!--
解答分析：

1. authors 先建立，因為 books 要參照它。

2. books 的 isbn 加了 UNIQUE，確保 ISBN 不重複。UNIQUE 欄位允許 NULL，所以如果某本書沒有 ISBN 也可以插入。

3. members 的 joined_date 使用 DEFAULT (CURRENT_DATE)，注意括號是必要的——MySQL 8.0.13+ 才支援欄位預設值用函式（括號是語法要求）。

4. borrowings 的 return_date 沒有 NOT NULL，表示允許 NULL。這很合理：書借出去但還沒還，return_date 就是 NULL。

⚠️ 注意：這裡 borrowings 用了自增的 id 作為主鍵，而不是 (member_id, book_id) 的複合主鍵。因為同一個會員可能借同一本書多次，複合主鍵會限制這個情況。
-->

---
layout: default
---

# 練習 2：任務說明
### 修改現有結構

假設 `products` 表已建立，現在有以下新需求：

1. 新增一個 `description TEXT` 欄位
2. `price` 欄位需要確保值大於 0（使用 CHECK 約束）
3. `category` 欄位改名為 `product_category`
4. 新增一個 `(product_category, is_active)` 複合索引提升查詢效率
5. 刪除暫時用的 `temp_note` 欄位

**任務：** 寫出對應的 ALTER TABLE 語句（可一次執行完所有修改）。

<!--
這題考驗大家對 ALTER TABLE 各種操作的熟悉程度。

提示：MySQL 8.0.16+ 才支援 CHECK 約束。

思考：哪些操作可以合併在一個 ALTER TABLE 語句裡？
-->

---
layout: default
---

# 練習 2：解題提示

```sql
-- 方式一：分開執行（每個操作獨立）
ALTER TABLE products ADD COLUMN description TEXT;

ALTER TABLE products
  ADD CONSTRAINT chk_price CHECK (price > 0);

ALTER TABLE products
  RENAME COLUMN category TO product_category;

ALTER TABLE products
  ADD INDEX idx_category_active (product_category, is_active);

ALTER TABLE products DROP COLUMN temp_note;

-- 方式二：合併執行（推薦，對大型表效率更高）
ALTER TABLE products
  ADD COLUMN description TEXT,
  ADD CONSTRAINT chk_price CHECK (price > 0),
  RENAME COLUMN category TO product_category,
  ADD INDEX idx_category_active (product_category, is_active),
  DROP COLUMN temp_note;
```

<!--
兩種方式都能達到目的，但方式二（合併執行）更有效率。

對於大型資料表，每次 ALTER TABLE 都可能需要重建整張表。分開執行 5 次，就重建 5 次；合併執行只重建 1 次，速度差別很大。

⚠️ 注意：CHECK 約束需要 MySQL 8.0.16+。如果你在舊版本執行，語法不會報錯，但約束完全不起作用。

RENAME COLUMN 也需要 MySQL 8.0+。舊版本要用 CHANGE COLUMN old_name new_name datatype 語法，而且需要重新指定欄位型別，容易出錯。
-->

---
layout: end
---

# Q & A

有任何問題嗎？

<!--
現在開放 Q&A 時間。

大家對 DDL 指令有沒有什麼疑問？

特別是 DROP、TRUNCATE、DELETE 三者的差別，如果還不太確定，歡迎現在提問。

記住：DDL 的操作大多是不可逆的，執行前一定要確認清楚！
-->
