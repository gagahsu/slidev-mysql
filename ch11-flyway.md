---
theme: penguin
class: text-center
highlighter: shiki
lineNumbers: true
drawings:
  persist: false
transition: slide-left
title: Flyway 資料庫版本控制
routeAlias: ch11
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
    Flyway 資料庫版本控制
  </h1>
  <div style="height: 4px; width: 320px; background: linear-gradient(90deg, #5eada0, #a7d9d0); border-radius: 2px; margin-bottom: 1.5rem;"></div>
  <p style="color: #4a7c7c; font-size: 1.15rem; font-style: italic;">
    「程式碼有 Git，資料庫也該有版本控制」
  </p>
  <Link to="home" style="color: #9dc4c4; font-size: 0.85rem; margin-top: 2rem; text-decoration: none; letter-spacing: 0.05em;">← 返回目錄</Link>
</div>

<!--
大家好，歡迎來到第十一章：Flyway 資料庫版本控制。

程式碼有 Git，大家拉下來都一樣。資料庫呢？我們在自己電腦加了一個欄位，同事、測試機、正式機都沒有。

Flyway 就是來解決這件事的。學完這章，大家就能讓資料庫的變更，像程式碼一樣被版本控制、被自動套用。
-->

---
layout: default
---

# Outline

- **為什麼需要資料庫版本控制** — 手動改 schema 的痛點
- **Flyway 是什麼** — 運作原理與 `flyway_schema_history`
- **Migration 檔案命名規則** — Prefix、Version、Separator、Description
- **三種 Migration 類型** — Versioned（V）、Repeatable（R）、Undo（U）
- **在 Spring Boot 中使用 Flyway** — 依賴、設定、目錄結構
- **常用指令與常見錯誤** — migrate / info / validate / baseline / repair

<!--
這一章分成三個部分。第一部分講為什麼，沒有版本控制會遇到什麼麻煩，Flyway 又用什麼機制解決。第二部分講怎麼寫，migration 檔案的命名規則、三種類型，以及最容易卡住新手的 checksum。第三部分講怎麼用，把 Flyway 整合進 Spring Boot，再整理常用指令和常見錯誤。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第一部分
# 為什麼需要資料庫版本控制？

<!--
我們先從一個很常見的情境開始，看看沒有版本控制的資料庫會怎樣。
-->

---

# 沒有版本控制的資料庫

想像一個三人團隊，你在本機的 `users` 表加了一個 `phone` 欄位，然後呢？

| 情境 | 沒有 Flyway | 有 Flyway |
| --- | --- | --- |
| 同事拉了新程式碼 | 程式報錯：`Unknown column 'phone'` | 啟動時自動補上欄位 |
| 部署到測試機 | 手動連進去下 `ALTER TABLE` | 部署時自動執行 |
| 部署到正式機 | 半夜連線，祈禱不要打錯字 | 和測試機執行完全相同的腳本 |
| 想知道現在是哪個版本 | 問人、翻聊天記錄 | 查 `flyway_schema_history` 表 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>核心問題：</b>程式碼的變更有 Git 記錄，資料庫的變更卻只存在某個人的記憶裡。
</div>

<!--
想像一個三人團隊。我們在本機的 `users` 表加了一個 `phone` 欄位，程式跑得好好的。推上去之後，同事拉下程式碼一啟動，就報錯找不到 phone 這個欄位。

因為我們推上去的只有程式碼，資料庫的變更沒有跟著走。表格裡其他情境更麻煩，部署正式機得半夜手動貼 SQL，想知道目前版本只能問人。

畫面下方這句話就是核心問題：「程式碼的變更有 Git 記錄，資料庫的變更卻只存在某個人的記憶裡。」Flyway 要做的，就是把這些 SQL 變成檔案放進 Git，讓程式自動執行。
-->

---

# Flyway 是什麼？

「Flyway 是一套 SQL 優先（SQL-first）的資料庫版本控制工具，它把每次 schema 變更寫成一個檔案，依照順序執行一次，並把執行記錄存進資料庫。」

| 特性 | 說明 |
| --- | --- |
| **SQL 檔案即版本** | 每個變更是一個 `.sql` 檔，可以進 Git 版控 |
| **只執行一次** | 執行過的 migration 不會重複執行 |
| **嚴格順序** | 依照版本號由小到大依序執行 |
| **有記錄可查** | 執行結果寫進 `flyway_schema_history` 表 |
| **檢查竄改** | 用 checksum 比對檔案是否被改過 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>類比：</b>Flyway 就像資料庫的「存摺」——每一筆交易都有順序、有金額、有日期，而且不能事後塗改。
</div>

<!--
「Flyway 是一套 SQL 優先的資料庫版本控制工具，它把每次 schema 變更寫成一個檔案，依照順序執行一次，並把執行記錄存進資料庫。」

這裡有兩個關鍵字，「依照順序」和「一次」。依照順序，代表 V1 一定在 V2 之前執行，在哪台機器跑結果都一樣。只執行一次，代表程式重開一百次，V1 也只會跑一次，因為 Flyway 會查記錄，知道它跑過了。

我們可以用存摺來理解。存摺上每一筆交易都有順序、有日期，印上去之後就不能塗改。表格最後一列的 checksum，就是在做防塗改這件事，等一下會細講。
-->

---

# Flyway 的運作流程

Flyway 啟動時做的事情，其實只有四步：

| 步驟 | Flyway 做的事 |
| --- | --- |
| 1. 掃描 | 掃描指定目錄（預設 `db/migration`）下所有符合命名規則的檔案 |
| 2. 查表 | 讀取 `flyway_schema_history`，知道目前資料庫在哪個版本 |
| 3. 比對 | 找出「檔案有、但記錄表沒有」的 migration，稱為 pending |
| 4. 執行 | 依版本號由小到大執行 pending migration，每支包在一個 transaction 裡 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>Idempotent（冪等）：</b>不管目前資料庫在哪個版本，執行 migrate 都是安全的——已跑過的不會再跑一次。
</div>

<!--
Flyway 啟動時做的事，只有表格裡這四步。

第一步掃描，到 `db/migration` 目錄，把符合命名規則的檔案找出來。第二步查表，讀取 `flyway_schema_history`，知道資料庫目前在哪個版本。第一次執行時，這張表會自動建立。第三步比對，例如檔案有 V1 到 V3，記錄只有 V1 和 V2，V3 就是待執行的 pending。第四步執行，依版本號由小到大跑完，每一支都包在交易裡。

因為有查表和比對，migrate 是冪等的。連續執行十次，效果跟一次完全一樣，所以可以放心把它放進部署流程。
-->

---

# flyway_schema_history 記錄表

Flyway 第一次執行時會自動建立這張表，它就是資料庫的「版本存摺」：

| 欄位 | 說明 |
| --- | --- |
| `installed_rank` | 執行順序（第幾支被跑的）|
| `version` | 版本號，例如 `1`、`2.1`（Repeatable 為 NULL）|
| `description` | 檔名中的描述文字 |
| `type` | migration 類型，例如 `SQL` |
| `script` | 實際的檔案名稱 |

<!--
`flyway_schema_history` 是 Flyway 的核心，第一次使用時，很建議打開來看一眼，馬上就懂它在做什麼。

每成功執行一支 migration，Flyway 就在這裡新增一筆。這頁先看前五個欄位。

`installed_rank` 是實際的執行順序，不一定等於版本號的順序。如果之後補了一支版本號較小的檔案，它還是排在後面，因為它比較晚被執行。

`version` 是版本號，如果是 NULL，代表這是 Repeatable migration，第二部分會講。`description` 和 `script` 分別是檔名裡的描述和完整檔名。`type` 記錄寫法，最常見的是 SQL。
-->

---

# flyway_schema_history 記錄表（續）

| 欄位 | 說明 |
| --- | --- |
| `checksum` | 檔案內容的指紋，用來偵測檔案是否被改過 |
| `installed_by` | 執行的資料庫使用者 |
| `installed_on` | 執行時間 |
| `execution_time` | 這支 migration 跑了多久（毫秒）|
| `success` | 這支 migration 是否成功 |

<!--
接著是剩下的五個欄位。

最需要注意的是 `checksum`。它是用檔案內容算出來的指紋，內容改了一個字，checksum 就會變。Flyway 每次啟動，都會拿現在檔案的 checksum 跟記錄表比對，不一樣就直接報錯。這是刻意的設計，已經執行過的 SQL，改了檔案，資料庫也不會變回去。

`installed_by` 和 `installed_on` 記錄誰在什麼時候執行，方便事後追查。`execution_time` 記錄花了多少毫秒，部署突然變慢時，可以用它找出是哪一支拖慢的。

`success` 記錄是否成功，這跟後面要講的 repair 指令有關。
-->

---

# 查看記錄表 — 範例

```sql
-- 看目前資料庫跑到哪個版本了
SELECT installed_rank, version, description, script, success
FROM flyway_schema_history
ORDER BY installed_rank;
```

執行結果：

| installed_rank | version | description | script | success |
| --- | --- | --- | --- | --- |
| 1 | 1 | create users table | `V1__create_users_table.sql` | 1 |
| 2 | 2 | add phone to users | `V2__add_phone_to_users.sql` | 1 |
| 3 | NULL | create user summary view | `R__create_user_summary_view.sql` | 1 |

<!--
這是實際查詢記錄表的樣子，依執行順序列出每一支 migration。

執行後可以看到三筆資料，依序是建立 users 表、加上 phone 欄位，以及建立一個 VIEW。第三筆的 version 是 NULL，因為它是 Repeatable migration，沒有版本號。

success 都是 1，代表全部成功。如果某一筆是 0，代表那支執行到一半失敗了，Flyway 下次啟動會拒絕繼續，要我們先處理乾淨。

這張表就是普通的資料表，前面學過的 SELECT 都能用。不過千萬不要手動 UPDATE 或 DELETE 它，除非非常清楚自己在做什麼。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第二部分
# Migration 檔案怎麼寫？

<!--
了解原理之後，第二部分來看檔案怎麼寫。Flyway 的命名規則是強制的，取錯名字它根本不理。
-->

---

# 命名規則：五個組成部分

Flyway 靠「檔名」判斷這支 migration 是什麼、什麼時候跑，格式固定為：

`<Prefix><Version>__<Description>.<Suffix>`

| 組成 | 內容 | 說明 |
| --- | --- | --- |
| **Prefix** | `V` / `R` / `U` | 類型：Versioned、Repeatable、Undo |
| **Version** | `1`、`2.1`、`20240815` | 版本號，用 `.` 或 `_` 分隔，必須唯一 |
| **Separator** | `__` | **兩條**底線，不是一條 |
| **Description** | `create_users_table` | 描述文字，底線會顯示成空格 |
| **Suffix** | `.sql` | 副檔名，預設為 `.sql` |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
⚠️ <b>最常見的錯誤：</b>分隔符號打成一條底線 `V1_create_users.sql`，Flyway 會直接忽略這個檔案。
</div>

<!--
Flyway 完全靠檔名判斷事情，格式固定是 Prefix、Version、兩條底線、Description，最後是副檔名。

Prefix 決定類型，V 最常用。Version 可以是流水號、2.1 這種階層式，或日期，必須唯一，而且照數字大小排序。

Separator 是兩條底線，這是最多人踩的坑。只寫一條底線，Flyway 會認為這不是它的檔案，直接忽略，不報錯也不警告，就是安靜地不執行。

Description 自由填寫，用底線分隔單字，記錄表裡會顯示成空格。
-->

---

# 命名規則 — 範例

```text
db/migration/
├── V1__create_users_table.sql          ✅ 版本 1
├── V2__add_phone_to_users.sql          ✅ 版本 2
├── V2.1__create_index_on_phone.sql     ✅ 版本 2.1（在 V2 之後、V3 之前）
├── V3__create_orders_table.sql         ✅ 版本 3
├── R__create_user_summary_view.sql     ✅ 可重複執行，最後才跑
├── V1_wrong_separator.sql              ❌ 只有一條底線，被忽略
└── V2__duplicate_version.sql           ❌ 版本號重複，啟動時報錯
```

<!--
這是一個典型的 migration 目錄。

注意 V2.1，它會排在 V2 之後、V3 之前。團隊協作時很好用，如果兩個人都拿了 V3，其中一人可以改用 V2.1，避免撞號。

R 開頭的檔案沒有版本號，會在所有 V 都跑完之後才執行。

最後兩個是反面教材。`V1_wrong_separator` 只有一條底線，會被安靜地忽略。`V2__duplicate_version` 跟前面的 V2 版本號重複，Flyway 啟動時就會直接報錯。
-->

---

# Versioned Migration（V）

「Versioned migration 有版本號、只執行一次，是最常用的類型。」用來做任何**不可重複執行**的變更：

```sql
-- V1__create_users_table.sql
CREATE TABLE users (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>為什麼不能重複執行？</b>`CREATE TABLE` 跑第二次會報 <code>Table 'users' already exists</code>，所以它必須是 Versioned。
</div>

<!--
「Versioned migration 有版本號、只執行一次，是最常用的類型。」大部分時間我們寫的都是它。

它適合所有跑第二次就會出事的操作，例如 CREATE TABLE、ALTER TABLE、DROP COLUMN，以及新增初始資料。

以這支 V1 為例，它建立了 users 表。如果沒有只執行一次的機制，第二次啟動就會報錯說 users 已經存在，整個應用起不來。

寫 Versioned migration 有個心法：一支只做一件事。不要把建三張表、塞初始資料、加索引全部擠進 V1。拆成好幾支，出事時一眼就知道是哪一支的問題。
-->

---

# Versioned Migration — 修改結構

第二次變更就寫成新的檔案，**永遠不要回頭改舊檔案**：

```sql
-- V2__add_phone_to_users.sql
ALTER TABLE users ADD COLUMN phone VARCHAR(20);

-- V3__create_orders_table.sql
CREATE TABLE orders (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);
```

<!--
這頁是 Flyway 最重要的心法：「永遠往前加，不要往回改。」

要加 phone 欄位，正確做法是新增一支 V2，寫 `ALTER TABLE` 加欄位。要建訂單表，就再新增一支 V3。

錯誤做法是回頭修改 V1，把 phone 直接加進建表語句。為什麼不行？因為 V1 在我們的電腦、同事的電腦、測試機上都已經執行過了。改了檔案，那些資料庫不會有任何變化，下次啟動時只會發現 checksum 對不上，直接拒絕啟動。

用存摺來想就很清楚。上個月領了一千元，這個月覺得不該領，不能拿立可白塗改上個月那一行，只能這個月再存一千元回去。
-->

---

# Repeatable Migration（R）

「Repeatable migration 沒有版本號，只要檔案內容（checksum）變了就會重新執行。」

| 特性 | 說明 |
| --- | --- |
| 檔名 | `R__description.sql`，**沒有版本號** |
| 執行時機 | 所有 versioned migration 跑完之後，最後才執行 |
| 重複條件 | checksum 改變時重新執行；沒改就跳過 |
| 執行順序 | 多支 R 之間，依 description 字母順序執行 |
| 適用對象 | VIEW、STORED PROCEDURE、FUNCTION、TRIGGER |

<!--
「Repeatable migration 沒有版本號，只要檔案內容變了就會重新執行。」它的邏輯跟 Versioned 剛好相反。

為什麼需要它？想想第九章的 VIEW。`CREATE OR REPLACE VIEW` 本來就能重複執行，每次都用最新的定義蓋掉舊的。如果用 Versioned 來管，每改一次就要開一個新版本，想知道 VIEW 現在長什麼樣子，還得把好幾個檔案拼起來讀。

用 Repeatable 就乾淨多了，一個 VIEW 一個檔案，內容永遠是最新的完整定義，改了就自動重跑。

表格裡要注意執行時機，所有 R 都在 V 全部跑完之後才執行，因為 VIEW 可能依賴新建的表。
-->

---

# Repeatable Migration — 範例

```sql
-- R__create_user_summary_view.sql
CREATE OR REPLACE VIEW user_summary AS
SELECT u.id, u.name, COUNT(o.id) AS order_count, SUM(o.amount) AS total
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name;
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
⚠️ <b>務必用可重複執行的語法：</b><code>CREATE OR REPLACE</code>、<code>DROP IF EXISTS</code>。若寫成單純的 <code>CREATE VIEW</code>，第二次執行就會報錯。
</div>

<!--
這是一支典型的 Repeatable migration，建立一個統計每位使用者訂單數和總金額的 VIEW。

重點在第一行的 `CREATE OR REPLACE VIEW`。這支檔案隨時可能再跑一次，所以裡面每一行都必須是重複執行也不會出事的寫法。如果寫成單純的 `CREATE VIEW`，第二次執行就會報錯說 VIEW 已經存在。

MySQL 常用的可重複寫法有兩種，`CREATE OR REPLACE VIEW`，以及先 `DROP PROCEDURE IF EXISTS` 再建立預存程序。

執行後，記錄表裡這一筆的 version 是 NULL，這就是 Repeatable 的特徵。
-->

---

# Undo（U）與 Baseline（B）

| Prefix | 名稱 | 用途 | 注意 |
| --- | --- | --- | --- |
| `U` | Undo Migration | 撤銷對應版本的 versioned migration | **僅商業版支援** |
| `B` | Baseline Migration | 把多支歷史 migration 壓縮成一個起始快照 | 加速全新環境建置 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>實務建議：</b>不要依賴 Undo。正式環境要「還原」時，正確做法是寫一支新的 versioned migration 把變更改回來，而不是回頭撤銷。
</div>

<!--
除了 V 和 R，還有兩種 prefix 可能會看到。

U 是 Undo，用來撤銷對應版本，例如 U2 撤銷 V2。聽起來很好，但有兩個現實問題。第一，它只有商業版支援。第二，很多變更根本無法真正撤銷。V2 如果刪掉了 phone 欄位，U2 可以把欄位加回來，但裡面的資料已經沒了。

所以實務建議是不要依賴 Undo。正式環境要改回來，就寫一支新的 Versioned migration，讓變更歷史保持完整、線性。

B 是 Baseline，用在專案累積了上百支 migration 的時候。做一個快照，讓全新環境直接從那個狀態開始，不用從 V1 一路跑。
-->

---

# Checksum：為什麼不能改舊檔案？

Flyway 每次啟動都會比對「檔案的 checksum」與「記錄表的 checksum」：

| 情況 | Flyway 的反應 |
| --- | --- |
| checksum 一致 | 正常，跳過已執行的 migration |
| checksum 不一致 | 啟動失敗：`Migration checksum mismatch` |
| 檔案被刪除 | 啟動失敗：`Detected applied migration not resolved locally` |
| 有新版本號 | 執行該支 pending migration |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
⚠️ <b>連空白和註解都算：</b>checksum 是整個檔案內容算出來的，改一個空格也會不一致。
</div>

<!--
這頁是整章最重要的觀念，也是新手最常卡住的地方。

Flyway 每次啟動，都會把已執行過的檔案重算 checksum，跟記錄表比對。不一致就直接啟動失敗，錯誤訊息是 checksum mismatch。已執行的檔案被刪除，也一樣會報錯。

很多人會覺得很煩，只是加了一行註解而已。但 Flyway 分不出我們改的是註解，還是把欄位長度從五十改成一百。

這時候最安全的做法，就是停下來讓人處理。checksum 保護的，是「資料庫真的長成我們以為的樣子」。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第三部分
# 在專案中使用 Flyway

<!--
第三部分，我們把 Flyway 裝進 Spring Boot 專案，再看常用指令和實務上會遇到的問題。
-->

---

# Spring Boot 整合 — 加入依賴

Spring Boot 對 Flyway 有內建支援，加入依賴後**啟動時就會自動執行 migrate**：

```xml
<dependency>
  <groupId>org.flywaydb</groupId>
  <artifactId>flyway-core</artifactId>
</dependency>
<dependency>
  <groupId>org.flywaydb</groupId>
  <artifactId>flyway-mysql</artifactId>
</dependency>
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>Flyway 10 以後：</b>MySQL、PostgreSQL 等資料庫的支援被拆成獨立模組，除了 <code>flyway-core</code> 還要加上對應的 <code>flyway-mysql</code>。
</div>

<!--
在 Spring Boot 裡用 Flyway，幾乎不用寫程式，加上依賴就好。

Spring Boot 偵測到 `flyway-core`，就會在應用啟動時自動執行 migrate。時間點是在建立資料庫連線之後、JPA 初始化之前。這個順序很重要，migration 先跑完，Hibernate 才去檢查 entity 跟資料表對不對得上。

第二個依賴 `flyway-mysql` 是 Flyway 10 之後才需要的。以前所有資料庫的支援都放在 core 裡，後來拆成獨立模組。如果只加 core 就連 MySQL，會看到 Unsupported Database 的錯誤，原因就是少了這一個。

版本號不用寫，Spring Boot 會自動選好相容的版本。
-->

---

# Spring Boot 整合 — 常用設定

| 設定 | 預設值 | 說明 |
| --- | --- | --- |
| `spring.flyway.enabled` | `true` | 是否啟用 Flyway |
| `spring.flyway.locations` | `classpath:db/migration` | migration 檔案存放位置 |
| `spring.flyway.baseline-on-migrate` | `false` | 對既有資料庫自動建立 baseline |
| `spring.flyway.validate-on-migrate` | `true` | 執行前先驗證 checksum |
| `spring.flyway.clean-disabled` | `true` | 禁用 clean（刪光所有物件）|
| `spring.jpa.hibernate.ddl-auto` | — | 用 Flyway 時**必須設為 `none`** |

<!--
表格整理了實務上最常調整的設定。

`locations` 是檔案位置，通常不用改。`baseline-on-migrate` 用在資料庫已經有表、卻沒有記錄表的情況，等一下會講。

最後一行要特別注意，用了 Flyway，`ddl-auto` 一定要設成 none。Hibernate 的 update 模式也會去改資料表結構，兩個工具同時管 schema，結構就會跟 migration 檔案對不上，而且沒有任何記錄告訴我們是誰改的。

所以讓 Flyway 全權負責結構，Hibernate 只負責讀寫資料。
-->

---

# Spring Boot 整合 — 設定與目錄

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/shop
spring.datasource.username=root
spring.datasource.password=pass1234

spring.jpa.hibernate.ddl-auto=none
spring.flyway.enabled=true
spring.flyway.locations=classpath:db/migration
```

專案目錄結構：

```text
src/main/resources/db/migration/
├── V1__create_users_table.sql
└── V2__create_orders_table.sql
```

<!--
這是一份完整可用的設定。

上半段是資料庫連線，跟平常一樣。接著是剛才強調的 `ddl-auto=none`。最後兩行 Flyway 的設定，其實都是預設值，寫不寫都一樣，列出來是讓大家知道可以調整。

migration 檔案就放在 `src/main/resources/db/migration` 底下。Flyway 會往下層目錄掃描，檔案多了可以再分子目錄。

設定好之後直接啟動，console 會印出成功套用了兩支 migration。再去資料庫看，users 和 orders 兩張表就建好了。
-->

---

# 常用指令

除了 Spring Boot 自動執行，Flyway 也可以用 CLI 或 Maven plugin 手動操作：

| 指令 | 用途 |
| --- | --- |
| `migrate` | 執行所有 pending migration（最常用）|
| `info` | 列出每支 migration 的狀態：Pending / Success / Failed |
| `validate` | 驗證檔案與記錄表是否一致，不執行任何變更 |
| `baseline` | 為既有資料庫建立起始版本，之前的變更視為已完成 |
| `repair` | 修復記錄表：移除失敗記錄、重算 checksum |
| `clean` | **刪除 schema 下所有物件**，正式環境務必禁用 |

<!--
除了 Spring Boot 自動執行，Flyway 也能用 CLI 或 Maven plugin 手動操作。表格裡的六個指令，大致依使用頻率排列。

`migrate` 最常用，把還沒跑的都跑完。`info` 不會改任何東西，只列出每支 migration 的狀態，部署前先看一眼可以避免很多意外。`validate` 只驗證不執行，適合放進 CI 當檢查。

`baseline` 和 `repair` 是救火用的，下一頁會看到。

最後的 `clean` 要特別小心，它會刪光整個 schema 的所有東西，資料表、資料、VIEW 全部。本機開發想重來時很方便，在正式環境執行就是災難。所以新版 Flyway 預設把它鎖起來，正式環境絕對不要打開。
-->

---

# 常用指令 — 範例

```bash
# 使用 Maven plugin
mvn flyway:info       # 查看目前狀態
mvn flyway:migrate    # 執行待處理的 migration
mvn flyway:validate    # 驗證檔案與記錄表一致

# 使用 Flyway CLI
flyway -url=jdbc:mysql://localhost:3306/shop -user=root info
```

`flyway info` 的輸出：

```text
+-----------+---------+---------------------+---------+
| Category  | Version | Description         | State   |
+-----------+---------+---------------------+---------+
| Versioned | 1       | create users table  | Success |
| Versioned | 2       | create orders table | Pending |
+-----------+---------+---------------------+---------+
```

<!--
這是實際操作的樣子。上面是 Maven plugin 的用法，適合已經有 Maven 專案的情況。下面是 CLI，適合手上沒有專案、只想檢查資料庫的情況，例如 DBA 要看正式環境的狀態。

重點看 `info` 的輸出。V1 是 Success，V2 是 Pending，代表現在執行 migrate，只會跑 V2。

State 還有一個常見的值叫 Ignored。如果補了一支版本號比資料庫目前版本還小的檔案，Flyway 會認為它來不及了，直接跳過。

所以團隊協作時要協調好版本號，或改用時間戳，就不太會遇到這個問題。
-->

---

# 常見錯誤與處理

| 錯誤訊息 | 原因 | 處理方式 |
| --- | --- | --- |
| `Migration checksum mismatch` | 改了已執行過的檔案 | 把檔案改回去；或執行 `repair` 重算 checksum |
| `Found non-empty schema without schema history table` | 資料庫已有資料表但無記錄表 | 設 `baseline-on-migrate=true` |
| `Detected failed migration to version X` | 某支 migration 執行到一半失敗 | 手動清乾淨半套的變更，再執行 `repair` |
| `Unsupported Database: MySQL` | Flyway 10+ 缺少資料庫模組 | 加入 `flyway-mysql` 依賴 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
⚠️ <b>MySQL 的 DDL 不支援 transaction rollback：</b>migration 中途失敗時，已執行的 <code>ALTER TABLE</code> 不會自動還原，必須手動處理。
</div>

<!--
表格裡的四個錯誤，涵蓋了新手大部分會遇到的狀況。

第一個是 checksum mismatch。最乾淨的做法是把檔案改回原樣。只有確定 SQL 的效果沒變，例如只加了註解，才用 `repair` 重算。

第二個是接手既有專案時，資料庫有表卻沒有記錄表。設定 `baseline-on-migrate=true`，Flyway 會把現有狀態當成起點。

第三個是執行失敗。畫面下方提醒了 MySQL 特有的坑，DDL 不能回復。三行 ALTER TABLE 第二行失敗，第一行的變更會留著。所以要先手動清乾淨，再執行 repair。

第四個就是少了 `flyway-mysql` 依賴。
-->

---

# 團隊協作的實務原則

| 原則 | 說明 |
| --- | --- |
| 已上線的 migration 一律不改 | 要修正就寫新的一支 |
| 一支 migration 只做一件事 | 出錯時容易定位、容易收拾 |
| migration 檔案跟程式碼一起進 Git | 同一個 commit、同一個 PR |
| 版本號用時間戳 | `V20240815103000__xxx.sql`，避免多人版本號打架 |
| 正式環境永久禁用 `clean` | `spring.flyway.clean-disabled=true` |
| 部署前先跑 `info` | 確認要執行哪些 migration，不要盲目部署 |

<!--
最後整理六個團隊協作的實務原則，這些都是踩過坑才會知道的事。

第一條最重要，已上線的 migration 一律不改，這是紀律問題。第二條，一支只做一件事，出錯時才好收拾。

第三條常被忽略，migration 檔案要跟對應的程式碼放在同一個 commit。這樣任何人切到任何一個版本，程式和資料庫結構都是配對的。

第四條是用時間戳當版本號。三人以上的團隊，用流水號很容易兩個人都寫了 V5，用時間戳就幾乎不會撞號。

最後兩條，正式環境永遠禁用 clean，部署前先跑一次 info，清楚知道這次部署會動到哪些東西。
-->

---
layout: default
---

# 練習 1：任務說明
### 幫既有的專案導入 Flyway

你接手一個 Spring Boot 專案，目前用 `spring.jpa.hibernate.ddl-auto=update` 管理 schema，資料庫已經有 `products` 和 `categories` 兩張表和大量正式資料。

現在需求是：為 `products` 加上 `stock` 欄位（整數，預設 0）。

**任務：**
1. 說明導入 Flyway 需要調整哪些設定（至少 3 項）
2. 寫出這支 migration 的**完整檔名**與 SQL 內容
3. 說明為什麼不能直接繼續用 `ddl-auto=update`

<!--
第一題是實務上最常見的情境。我們接手一個 Spring Boot 專案，原本用 `ddl-auto=update` 管理結構，資料庫裡已經有兩張表和大量正式資料。現在要幫 `products` 加上一個預設為零的 `stock` 欄位。

任務有三個。說明導入 Flyway 要調整哪些設定，至少三項。寫出這支 migration 的完整檔名和 SQL。最後說明為什麼不能繼續用 `ddl-auto=update`。

可以想想看，「資料庫已經有表了」這個條件，會觸發哪個問題？版本號又該從幾開始？

我們先暫停一下，自己想想看。

【講師】給大家十分鐘，可以提醒回頭看設定表和常見錯誤那兩頁。
-->

---

# 練習 1：解題提示

| 設定 | 值 | 原因 |
| --- | --- | --- |
| `spring.jpa.hibernate.ddl-auto` | `none` | 交出 schema 控制權，避免兩個工具打架 |
| `spring.flyway.baseline-on-migrate` | `true` | 資料庫非空且無記錄表，需要建立起點 |
| `spring.flyway.clean-disabled` | `true` | 有正式資料，絕不能被 clean |

```sql
-- V2__add_stock_to_products.sql
ALTER TABLE products ADD COLUMN stock INT NOT NULL DEFAULT 0;
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>為何不用 ddl-auto=update：</b>它由 Hibernate 推測差異、無執行記錄、不會刪欄位，且各環境結果可能不一致——無法審查、無法重現。
</div>

<!--
我們來看解答。三項設定分別是：`ddl-auto` 設成 none，把結構的控制權交出來。`baseline-on-migrate` 設成 true，因為資料庫不是空的。`clean-disabled` 設成 true，因為裡面有正式資料。

檔名是 V2 而不是 V1，因為 baseline 會把現有狀態記成版本一，第一支 migration 從 V2 開始比較安全。

SQL 要注意 `DEFAULT 0`。表裡已經有資料，如果只寫 `NOT NULL` 不給預設值，MySQL 不知道現有的資料要填什麼。

至於 `ddl-auto=update` 的問題，它的變更是 Hibernate 推測出來的，事前沒辦法審查，事後也沒有記錄，各環境的結果還可能不一致。它適合本機隨手開發，不適合需要審查和重現的環境。
-->

---
layout: default
---

# 練習 2：任務說明
### 判斷 migration 類型與除錯

團隊有以下四個需求，請判斷各自該用什麼類型的 migration：

1. 新增一張 `coupons` 優惠券資料表
2. 修改 `user_summary` 這個 VIEW 的統計邏輯（本月第三次修改）
3. 為 `orders` 表的 `created_at` 加上索引
4. 修正 `V3__create_orders_table.sql` 裡打錯的欄位型別（**該檔案已上線兩週**）

**任務：**
1. 為每個需求寫出對應的檔名與類型
2. 說明第 4 題如果直接改舊檔案會發生什麼事

<!--
第二題把整章的觀念綜合起來。畫面上有四個需求：新增優惠券資料表、第三次修改 user_summary 這個 VIEW、幫訂單的建立時間加索引，以及修正 V3 裡打錯的欄位型別，而且那支檔案已經上線兩週了。

請大家為每個需求寫出檔名和類型，並說明第四題如果直接改舊檔案會發生什麼事。

判斷的方法是想一想，這件事重複執行會不會出事？第四題要特別注意「已上線兩週」這個條件，想想存摺上印好的那一行，能不能塗改？

我們先暫停一下，自己判斷看看。

【講師】給大家五到十分鐘，可以先請同學說說第四題的做法。
-->

---

# 練習 2：解題提示

| 需求 | 檔名 | 類型與理由 |
| --- | --- | --- |
| 新增 `coupons` 表 | `V4__create_coupons_table.sql` | V：`CREATE TABLE` 不可重複執行 |
| 修改 VIEW 邏輯 | `R__create_user_summary_view.sql` | R：改檔案內容即可，**不需要新檔名** |
| 加索引 | `V5__add_index_on_orders_created_at.sql` | V：重複 `CREATE INDEX` 會報錯 |
| 修正已上線的型別 | `V6__fix_orders_amount_type.sql` | V：**寫新的一支去修正，不改舊檔** |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
⚠️ <b>若直接改 V3：</b>所有已執行過 V3 的環境（同事本機、測試機、正式機）下次啟動都會因 <code>checksum mismatch</code> 而失敗，而且資料庫的型別**依然是錯的**。
</div>

<!--
我們來看解答。

新增資料表和加索引都是 V，重複執行會報錯。修改 VIEW 用 R，直接編輯原本那支檔案就好，不用新檔名。

第四題要寫一支新的 V6，用 ALTER TABLE 把型別改對。如果直接改 V3，所有跑過 V3 的環境下次啟動都會因為 checksum 不一致而失敗，而且資料庫裡的型別還是錯的。

所以「永遠往前加，不要往回改」要當成鐵則。
-->

---
layout: end
---

# Q & A

有任何問題嗎？

<!--
今天我們學了 Flyway，讓資料庫的變更也能進版本控制。最重要的三個觀念是：命名要用兩條底線，少一條會被安靜地忽略；已執行過的 migration 永遠不要改，要修正就往前寫新的一支；用了 Flyway，就把 `ddl-auto` 設成 none，結構只能有一個管理者。

守住這三條，Flyway 用起來就會非常順手。這門 MySQL 課程也到這裡告一段落，謝謝大家。

【講師】開放提問，可以請同學分享自己在專案中遇過的資料庫變更問題。
-->
