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
大家好，歡迎來到第四章：DDL 資料定義語言。

前三章我們都在紙上設計，談原則、談正規化、談關聯。從這一章開始，我們要真正動手，把設計好的結構在 MySQL 裡建出來。

就像封面那句話，「先蓋好房子，才能擺家具」。DDL 就是蓋房子的工具。學完這章，大家就能自己建立資料庫和資料表，也知道之後怎麼修改和刪除它們。
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
這一章的路線很直觀。先看 SQL 語言怎麼分類，DDL 在裡面扮演什麼角色。接著依序學三個動作：用 CREATE 建立結構，用 ALTER 修改結構，最後比較 DROP 和 TRUNCATE 這兩種刪除方式。最後用兩題練習，把一個完整的資料庫結構建出來。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第一部分
# 什麼是 DDL？

<!--
我們先釐清 SQL 的分類。後面幾章還會學 DQL 和 DML，先知道它們的分工會很有幫助。
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
SQL 依照用途可以分成四大類，剛開始學很容易混在一起。我們用一棟房子來想像。

DDL 像建築師，負責蓋房子、決定有幾個房間。DQL 像訪客，在房子裡找東西，也就是查詢資料。DML 像住戶，搬進家具、移動家具、丟掉家具，也就是新增、修改、刪除資料。DCL 則像門禁管理員，決定誰可以進哪個房間。

這一章專注在 DDL。要記得它操作的是「結構」，不是資料本身。`CREATE TABLE` 建立的是欄位的定義，表裡面一開始是空的。
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
「DDL 是用來定義資料庫結構的語法，包括建立、修改和刪除資料庫、資料表、索引等物件。」表格裡列了五個常用指令，`CREATE`、`ALTER`、`DROP`、`TRUNCATE`、`RENAME`，後面我們會一個一個練習。

這裡有一個非常重要的特性。DDL 在 MySQL 裡是自動提交的，執行完就確定了，沒辦法用 `ROLLBACK` 復原。

這跟之後要學的 DML 不一樣。DML 可以放在交易裡，做錯了還能撤銷。但 DDL 沒有後悔藥。

所以在執行 `DROP TABLE` 或 `ALTER TABLE` 這類操作之前，一定要先確認，也要先備份。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第二部分
# CREATE — 建立結構

<!--
接下來進入 CREATE。我們從建立資料庫開始，再到資料表和各種條件約束。
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
在建立資料表之前，我們得先有一個資料庫，就像蓋房子前要先有一塊地。

畫面上有三種寫法。最簡單的是 `CREATE DATABASE shop`。比較推薦的寫法，是同時指定字元集 `utf8mb4` 和排序規則。排序規則 `utf8mb4_unicode_ci` 裡的 ci，意思是不分大小寫，排序時小寫 a 和大寫 A 會被視為相同。

第三種加上了 `IF NOT EXISTS`，如果資料庫已經存在就不會報錯。這在部署用的腳本裡很常見，同一份腳本跑兩次也不會出問題。

最後的 `USE shop` 是切換到這個資料庫，之後的操作都會在 shop 裡進行。
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

<!--
有了資料庫，接著就要建立資料表。這頁是 `CREATE TABLE` 的語法結構，方括號裡的部分代表可以省略。

結構可以分成三層來看。最外層是表名，可以選擇加上 `IF NOT EXISTS`。括號裡面一行一個欄位，先寫欄位名稱，再寫資料型別，後面可以接約束條件，例如不能是空值。所有欄位寫完之後，可以再加上整張表的約束，像主鍵或外鍵。

最後一行是我們一直在用的兩個設定。`ENGINE=InnoDB` 讓這張表支援外鍵和交易，`DEFAULT CHARSET=utf8mb4` 讓它能存中文和 emoji。這兩個設定建議每次都明確寫上。

下一頁，我們把這個結構套進一個完整的例子。
-->

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
這段 SQL 建立了一張商品表，把最常用的約束都放進來了。

`id` 用 `AUTO_INCREMENT`，每新增一筆，MySQL 就自動給下一個編號。`name` 加了 `NOT NULL`，新增商品時一定要填名稱。

`sku` 是商品貨號，加了 `UNIQUE`，不能重複。它和主鍵的差別是，主鍵不能是 NULL，`UNIQUE` 欄位可以是 NULL。

`price` 和 `stock` 都有 `DEFAULT`，沒提供值的時候會自動填 0。價格用的是 `DECIMAL(10,2)`，總共十位數、其中兩位是小數。`created_at` 的預設值是目前時間，新增時會自動記錄。

執行後，我們就有一張帶著完整規則的 `products` 表，不合規則的資料會直接被擋下來。
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
條件約束就像馬路旁的護欄，確保資料不會跑出合理的範圍。表格把六種約束整理在一起。

`NOT NULL` 最常用，確保重要欄位不會漏填。`UNIQUE` 確保不重複，但它允許 NULL，而且好幾個 NULL 不算重複。`DEFAULT` 讓沒填的欄位有預設值。主鍵和外鍵我們前幾章已經很熟了。

這裡要特別提的是 `CHECK`，它可以自訂規則，例如價格一定要大於零。不過它是 MySQL 8.0.16 之後才真正生效。在更早的版本，語法不會報錯，可是 MySQL 根本不會檢查，這是一個很容易被忽略的陷阱。
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
索引就像一本書的目錄。有了目錄，我們能很快翻到想看的頁面。可是每次改書的內容，目錄也得跟著更新。

畫面上有三種建立方式。一般索引用 `CREATE INDEX`。唯一索引加上 `UNIQUE`，效果等同 UNIQUE 約束。複合索引則一次包含多個欄位，例如分類加價格。最後一行是用 `DROP INDEX` 刪除索引。

哪些欄位適合加索引呢？常出現在 WHERE 條件、JOIN 或排序裡的欄位。反過來，像是否上架這種只有零和一兩種值的欄位，加了索引幫助不大。

另外，主鍵和 `UNIQUE` 約束會自動建立索引，不用再手動加。索引的細節，我們在之後的索引章節會再深入。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第三部分
# ALTER — 修改結構

<!--
資料表建好之後，需求一定會變。接下來學 ALTER，在不刪資料的情況下修改結構。
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
`ALTER TABLE` 就像在家具都還在的情況下，把房子重新隔間。表格列出了它能做的各種修改。

最常用的是新增欄位 `ADD COLUMN`，和修改欄位型別 `MODIFY COLUMN`。

重新命名欄位用的 `RENAME COLUMN`，是 MySQL 8.0 才有的語法。舊版要用 `CHANGE COLUMN`，除了新名字還得重新寫一次型別，很容易寫錯。

要特別注意的是，在很大的資料表上執行 `ALTER TABLE`，MySQL 可能要重建整張表，期間會鎖住表格，其他查詢都得等。所以正式環境要選在離峰時段，或是使用專門的線上變更工具。
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
這段範例對商品表做了幾種常見的修改。

前面四個是一次做一件事：新增描述欄位、把名稱加長到五百字、把 `is_available` 改名成 `is_active`、刪除 `category` 欄位。

重點在最後一個範例。一個 `ALTER TABLE` 裡可以用逗號隔開，一次做好幾個修改，這裡同時新增了兩個欄位和一個索引。好處是 MySQL 只需要重建一次表格。在大表上，這可能讓修改時間少掉一大半。

執行後，`products` 的結構就照這些需求更新了，原本的資料都還在。

不過 `DROP COLUMN` 例外，被刪掉的欄位，資料會永久消失，執行前一定要確認真的不需要了。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第四部分
# DROP vs TRUNCATE

<!--
最後一部分是 DROP 和 TRUNCATE。兩個都跟刪除有關，但差別很大，是初學者最常搞混的地方。
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
「DROP TABLE 就像是把整棟房子拆掉，連地基都沒了。」它會刪掉表的結構，也刪掉所有資料。

畫面上的寫法，從刪除一張表、加上 `IF EXISTS` 的安全刪除、一次刪多張表，到刪除整個資料庫。`IF EXISTS` 的意思是，表存在才刪，不存在也不會報錯，跟 CREATE 的 `IF NOT EXISTS` 剛好是一對。

刪除被外鍵參照的表時，MySQL 會報錯。例如 `orders` 參照了 `customers`，就不能先刪 `customers`。所以範例裡一次刪多張表時，先寫 `order_items`，再寫 `orders`，也就是先刪子表、再刪父表。

這是正式環境裡最危險的操作之一。執行前一定要確認刪的是對的表，而且已經備份。
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
「TRUNCATE TABLE 就像是把房子裡的所有家具搬空，但房子本身還在。」資料全部清掉，結構保留下來。

畫面上把它跟 `DELETE FROM` 放在一起，兩個都能清空整張表。差別在 TRUNCATE 是直接重建一張空表，不會一筆一筆刪，所以快很多。

不過它有三個限制。第一，不能加 WHERE，只能整張清空。第二，`AUTO_INCREMENT` 會重新從 1 開始。第三，它在 MySQL 裡屬於 DDL，執行後沒辦法 `ROLLBACK`。

所以只想刪部分資料，用 `DELETE` 加條件。要清空整張表、而且確定不需要復原，才用 TRUNCATE。
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
這張表把三種刪除方式放在一起比較，我們用房子的比喻來記。

DROP 是拆掉整棟房子，結構和資料都沒了，要用就得重新 `CREATE TABLE`。TRUNCATE 是搬空所有家具，房子還在，編號會重新計算。DELETE 是挑特定的家具搬走，可以用 WHERE 選擇要刪哪些。

安全性也不一樣。DROP 最危險。TRUNCATE 至少保留了結構，但沒辦法復原。DELETE 最安全，因為它是 DML，放在交易裡做錯了還可以 `ROLLBACK`。

代價是 DELETE 要一筆一筆刪，速度最慢。
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
我們整理這一章。SQL 分成 DDL、DQL、DML、DCL 四類，DDL 負責定義結構。我們學了用 `CREATE` 建立資料庫、資料表和索引，搭配各種條件約束。用 `ALTER TABLE` 修改結構，而且可以合併成一次執行。最後是 `DROP` 拆掉整張表，`TRUNCATE` 清空資料保留結構。

最重要的提醒是，DDL 會自動提交，執行後無法復原，動手前一定要確認。

接下來我們先做兩題練習。下一章 DQL，就會在這些表上開始查詢資料。
-->

---
layout: default
---

# 練習 1：任務說明
### 建立動態問卷資料庫（schema.sql）

上一章我們設計好了六張表，現在要把它變成能實際執行的 `schema.sql`：

**任務：**
1. 建立資料庫 `dynamic_survey`（字元集 `utf8mb4`）
2. 依上一章的設計建立六張表（完整欄位見 `SURVEY-SPEC.md` §3）
3. 用**條件約束**保證資料品質：
   - `questions.type` 只能是 `SINGLE`、`MULTI`、`TEXT`
   - `surveys` 的結束日期不可早於開始日期
   - `users.role` 只能是 `USER`、`ADMIN`
   - `survey_responses` 的 `(survey_id, email)` 不可重複
4. 所有資料表使用 InnoDB，注意建表順序

<!--
上一章我們畫好了設計圖，這一題要把它真正蓋起來。之後的章節都會用到這個資料庫，所以請把結果存成 `schema.sql`。

除了建立六張表，還要用這一章學的約束，把資料品質的規則放進資料庫。

思考一下，六張表要用什麼順序建立？被參照的表要先存在，所以誰應該排最前面？

我們先暫停一下，自己動手寫寫看。

【講師】給大家十五分鐘，寫完可以直接執行，確認每張表都建立成功。
-->

---
layout: default
---

# 練習 1：解題提示（Part 1）

`users` 和 `surveys` 不參照別人，可以最先建立：

```sql
CREATE DATABASE IF NOT EXISTS dynamic_survey
  DEFAULT CHARACTER SET utf8mb4;
USE dynamic_survey;

CREATE TABLE users (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(50) NOT NULL,
  email      VARCHAR(100) NOT NULL UNIQUE,
  password   VARCHAR(100) NOT NULL,
  phone      VARCHAR(20),
  role       VARCHAR(10) NOT NULL DEFAULT 'USER',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chk_users_role
    CHECK (role IN ('USER', 'ADMIN'))
) ENGINE=InnoDB;
```

<!--
我們來看解答。先回答順序的問題，`users` 和 `surveys` 不參照任何人，所以排最前面。

`users` 的 `role` 加上 CHECK 約束，只接受兩個值。不管是程式寫錯還是有人手動輸入，都不會出現其他的角色名稱。

執行之後，資料庫和第一張表就建立好了。
-->

---
layout: default
---

# 練習 1：解題提示（Part 1 續）

```sql
CREATE TABLE surveys (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  title       VARCHAR(50) NOT NULL,
  description VARCHAR(300),
  start_date  DATE NOT NULL,
  end_date    DATE NOT NULL,
  published   TINYINT NOT NULL DEFAULT 0,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chk_survey_dates
    CHECK (end_date >= start_date)
) ENGINE=InnoDB;
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>資料庫是最後一道防線：</b>程式和前端也會檢查日期，但就算有人繞過程式直接寫資料庫，CHECK 一樣會擋下來。
</div>

<!--
`surveys` 的重點是這個 CHECK 約束，結束日期不可以早於開始日期。

程式和前端當然也會檢查，那為什麼資料庫還要再檢查一次？因為資料庫是最後一道防線，就算有人繞過程式直接寫入，也會被擋下來。

要注意的是，CHECK 約束需要 MySQL 8.0.16 以上才會真的生效，舊版本只會略過。
-->

---
layout: default
---

# 練習 1：解題提示（Part 2）

接著建立題目與選項，先從 `questions` 開始：

```sql
CREATE TABLE questions (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  survey_id   INT NOT NULL,
  title       VARCHAR(200) NOT NULL,
  type        VARCHAR(10) NOT NULL,
  required    TINYINT NOT NULL DEFAULT 0,
  order_index INT NOT NULL,
  INDEX idx_questions_survey (survey_id),
  CONSTRAINT chk_question_type
    CHECK (type IN ('SINGLE', 'MULTI', 'TEXT')),
  FOREIGN KEY (survey_id) REFERENCES surveys(id)
    ON DELETE CASCADE
) ENGINE=InnoDB;
```

<!--
接著是題目。題目參照問卷，所以要等 `surveys` 建好之後才能建立。

`type` 用 CHECK 限制只能是三種題型，這樣就不會出現小寫的 single，或其他打錯的值。

外鍵加上 `ON DELETE CASCADE`，問卷刪掉時，底下的題目也會一起刪除。
-->

---
layout: default
---

# 練習 1：解題提示（Part 2 續）

```sql
CREATE TABLE options (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  question_id INT NOT NULL,
  label       VARCHAR(100) NOT NULL,
  order_index INT NOT NULL,
  INDEX idx_options_question (question_id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
    ON DELETE CASCADE
) ENGINE=InnoDB;
```

<!--
選項參照題目，所以排在題目後面。

`options` 不是保留字，可以直接當表名。如果某些圖形化工具把它標成關鍵字，用反引號包起來就可以了。

執行之後，問卷、題目和選項這三層就串起來了。
-->

---
layout: default
---

# 練習 1：解題提示（Part 3）

最後建立作答紀錄與每一題的答案：

```sql
CREATE TABLE survey_responses (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  survey_id    INT NOT NULL,
  user_id      INT,
  name         VARCHAR(50) NOT NULL,
  phone        VARCHAR(20) NOT NULL,
  email        VARCHAR(100) NOT NULL,
  age          INT,
  submitted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_survey_email (survey_id, email),
  CONSTRAINT chk_response_age
    CHECK (age IS NULL OR age BETWEEN 1 AND 120),
  FOREIGN KEY (survey_id) REFERENCES surveys(id)
    ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE SET NULL
) ENGINE=InnoDB;
```

<!--
作答紀錄同時參照問卷和會員，所以要等這兩張表都建好。

`(survey_id, email)` 用複合唯一約束，保證同一個 Email 不能重複填同一份問卷。

年齡是選填，所以 CHECK 寫成可以是 NULL，或是介於一到一百二十之間。這樣沒填年齡的人可以正常送出，填了不合理的年齡才會被擋下來。
-->

---
layout: default
---

# 練習 1：解題提示（Part 3 續）

```sql
CREATE TABLE response_answers (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  response_id INT NOT NULL,
  question_id INT NOT NULL,
  answer_text VARCHAR(500),
  INDEX idx_answers_response (response_id),
  INDEX idx_answers_question (question_id),
  FOREIGN KEY (response_id) REFERENCES survey_responses(id)
    ON DELETE CASCADE,
  FOREIGN KEY (question_id) REFERENCES questions(id)
    ON DELETE CASCADE
) ENGINE=InnoDB;
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>建表順序：</b><code>users</code>、<code>surveys</code>、<code>questions</code>、<code>options</code>、<code>survey_responses</code>、<code>response_answers</code>。要重來時，反過來 DROP。
</div>

<!--
最後一張表參照作答紀錄和題目，所以排在最後面。

整理一下完整的順序，先是會員和問卷，再來是題目、選項，接著是作答紀錄，最後是答案。要重來的時候，刪除順序剛好相反。

把這些語法存成 `schema.sql`，就可以一次建立整個資料庫。課程也附了一份 `sql/schema.sql`，大家可以對照看看。
-->

---
layout: default
---

# 練習 2：任務說明
### 修改現有結構（需求變更）

請在練習用的資料庫 `ch04_practice` 建立第一版的 `surveys`，再依新需求修改：

```sql
CREATE TABLE surveys (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  title      VARCHAR(50) NOT NULL,
  start_date DATE NOT NULL,
  end_date   DATE NOT NULL,
  enabled    TINYINT NOT NULL DEFAULT 0,
  temp_note  VARCHAR(100)
) ENGINE=InnoDB;
```

1. 把 `enabled` 改名為 `published`
2. 新增 `created_at DATETIME`，預設為建立當下的時間
3. 新增 `(published, start_date, end_date)` 複合索引
4. `title` 不可為空字串（提示：`CHECK (CHAR_LENGTH(title) > 0)`）
5. 刪除暫時用的 `temp_note` 欄位

<!--
第二題的情境很常見，專案做到一半，需求改了。第一版把發佈欄位叫做 `enabled`，還留著一個暫時用的欄位。

請大家先建立第一版的資料表，再用 ALTER TABLE 完成這五個修改。

思考一下，這五個修改一定要分成五句執行嗎？能不能寫在同一個 ALTER TABLE 裡？

我們先暫停一下，自己動手試試看。

【講師】給大家十分鐘，提醒同學在 `ch04_practice` 練習，不要動到 `dynamic_survey`。
-->

---
layout: default
---

# 練習 2：解題提示

五個修改可以合併在同一個 `ALTER TABLE`：

```sql
ALTER TABLE surveys
  RENAME COLUMN enabled TO published,
  ADD COLUMN created_at DATETIME NOT NULL
    DEFAULT CURRENT_TIMESTAMP,
  ADD INDEX idx_pub_dates (published, start_date, end_date),
  ADD CONSTRAINT chk_title_not_empty
    CHECK (CHAR_LENGTH(title) > 0),
  DROP COLUMN temp_note;
```

<div class="mt-4 p-3 bg-yellow-50 border-l-4 border-yellow-400 text-gray-700 text-sm text-left">
⚠️ <b>新增 CHECK 時，MySQL 會檢查現有資料。</b>如果已經有空字串的標題，ALTER 會直接失敗，要先修正舊資料再加約束。
</div>

<!--
答案是可以合併。分開寫也能完成，不過對大型資料表來說，每次 ALTER 都可能花上不少時間，合併執行通常比較有效率。

執行後，欄位名稱改好了，也多了 `created_at` 和索引。這時候如果新增空字串的標題，CHECK 就會擋下來。

要注意的是，加上 CHECK 時，MySQL 也會檢查已經存在的資料。只要有一筆不符合，整個 ALTER 就會失敗，所以實務上要先修正舊資料。

至於索引的欄位順序為什麼這樣排，到索引那一章會再說明。
-->

---
layout: end
---

# Q & A

有任何問題嗎？

<!--
今天我們學會了 DDL 的三個核心動作：用 CREATE 建立、用 ALTER 修改、用 DROP 和 TRUNCATE 刪除，也比較了它們和 DELETE 的差別。

最重要的是記住，DDL 的操作大多不能復原，養成先確認、先備份的習慣。

下一章，我們要開始用 SELECT 從這些資料表裡查出想要的資料。我們下一章見。

【講師】開放提問，特別可以確認大家是否分得清 DROP、TRUNCATE、DELETE 三者的差別。
-->
