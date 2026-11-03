---
theme: penguin
class: text-center
highlighter: shiki
lineNumbers: true
drawings:
  persist: false
transition: slide-left
title: 資料庫設計原則
routeAlias: ch01
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
    資料庫設計原則
  </h1>
  <div style="height: 4px; width: 320px; background: linear-gradient(90deg, #5eada0, #a7d9d0); border-radius: 2px; margin-bottom: 1.5rem;"></div>
  <p style="color: #4a7c7c; font-size: 1.15rem; font-style: italic;">
    「良好的設計，是高效查詢的起點」
  </p>
  <Link to="home" style="color: #9dc4c4; font-size: 0.85rem; margin-top: 2rem; text-decoration: none; letter-spacing: 0.05em;">← 返回目錄</Link>
</div>

<!--
大家好，歡迎來到 MySQL 資料庫課程的第一章：資料庫設計原則。

很多人一開始學資料庫，就急著學 SELECT、學 JOIN，卻跳過了資料表要怎麼設計。可是設計不好，後面的查詢就會又慢又麻煩。

這一章我們要學的，就是業界工程師設計資料表時共同遵守的幾個原則。學完之後，大家就能自己規劃出一份乾淨、好維護的資料表結構。
-->

---
layout: default
---

# Outline

- **什麼是關聯式資料庫設計？** — 設計目標與好壞對比
- **核心設計原則** — 單一職責、PRIMARY KEY、FOREIGN KEY、資料型別、NULL
- **命名與慣例** — 讓資料庫「說人話」
- **練習題** — 動手設計你的第一個 schema

<!--
這一章我們會走四段路。先看看什麼是好的資料庫設計，設計不好會出什麼問題。接著學五個核心原則，從單一職責一路講到 NULL。然後聊命名慣例，讓資料庫「說人話」。最後用兩題練習，動手設計第一個 schema。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第一部分
# 什麼是關聯式資料庫設計？

<!--
我們先從最根本的問題開始：資料庫為什麼需要設計？設計不好又會怎樣？
-->

---

# 資料庫設計的目標

設計良好的資料庫，能讓資料「好維護、不重複、不出錯」。

| 設計目標 | 說明 |
| --- | --- |
| **減少資料冗餘** | 同一份資訊只存一次，不在多個地方重複 |
| **確保資料一致性** | 資料不因更新不完整而產生矛盾 |
| **維護資料完整性** | 透過約束條件確保資料合法 |
| **提升查詢效率** | 結構清晰的資料表，查詢更快更簡單 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>一句話定義：</b>「資料庫設計的目的，就是用最合理的結構儲存資料，讓存、改、查、刪都輕鬆。」
</div>

<!--
想像我們開了一家餐廳，用一本記事本記錄訂單。每來一筆訂單，就把客人的姓名、電話、地址重新抄一次。

這樣不只抄得很累，客人哪天換了電話，我們還得翻遍整本記事本一筆一筆改，很容易漏掉。

這就是「資料冗餘」帶來的麻煩。表格裡列的四個目標，減少冗餘、確保一致、維護完整、提升查詢效率，其實都在解決同一件事。

一句話來說，「資料庫設計的目的，就是用最合理的結構儲存資料，讓存、改、查、刪都輕鬆。」
-->

---

# 好設計 vs 壞設計

同樣是「訂單系統」，設計方式不同，差異巨大：

| 面向 | 壞設計 | 好設計 |
| --- | --- | --- |
| 客戶資料 | 每筆訂單都重複存客戶姓名、電話 | 客戶資料只存一次，訂單用 ID 參照 |
| 更新成本 | 客戶改電話要改所有訂單 | 只需修改客戶表的一筆資料 |
| 查詢效率 | 需要掃描大量重複資料 | 透過 JOIN 快速取得完整資訊 |
| 資料一致性 | 容易因漏改而產生矛盾資料 | 資料庫約束確保一致性 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>核心觀念：</b>「把不同的事情存在不同的表，再用關聯把它們連起來。」
</div>

<!--
同樣是訂單系統，我們用表格比較兩種設計。

壞設計是每筆訂單都重複存客人的姓名和電話。客人一改電話，就得改掉所有訂單，漏改一筆，資料就互相矛盾。

好設計是客人資料只存一次，訂單裡只記一個客戶 ID。客人改電話時，只要改客戶表裡的那一筆就好。

所以好設計不只是看起來整齊，而是真的讓維護變簡單。這裡的核心觀念是「把不同的事情存在不同的表，再用關聯把它們連起來」。這句話也是下一章正規化的基礎，大家先記住。
-->

---

# 壞設計示例：一張表塞所有東西

試想這樣一張 `orders` 表，有什麼問題？

```sql
CREATE TABLE orders (
  order_id       INT PRIMARY KEY AUTO_INCREMENT,
  customer_name  VARCHAR(100),
  customer_phone VARCHAR(20),
  customer_email VARCHAR(100),
  product_name   VARCHAR(100),
  product_price  DECIMAL(10,2),
  quantity       INT,
  order_date     DATE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
⚠️ <b>問題：</b>同一個客戶下了 10 筆訂單，客戶姓名和電話就重複存了 10 次。客戶改電話時，需要更新所有訂單資料，容易漏改！
</div>

<!--
我們來看一個具體的壞例子。這段 `CREATE TABLE` 建了一張 `orders` 表，大家先想想看，問題出在哪裡？

仔細看欄位，客戶的姓名、電話、email，和商品名稱、價格、數量，全部擠在同一張表裡。

假設 Alice 下了一百筆訂單，她的名字和電話就重複存了一百次。這不只浪費空間，更麻煩的是 Alice 換電話的時候，我們得更新一百筆資料。只要中途出錯，就會有些訂單是新電話、有些還是舊電話。

這種情況有兩個名字，一個叫「資料冗餘」，另一個叫「更新異常」。接下來的設計原則，就是要避免這兩個問題。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第二部分
# 核心設計原則

<!--
知道壞設計的問題後，我們來看五個核心原則，以後設計資料表就有依據了。
-->

---

# 原則一：每個表只儲存一件事

「單一職責原則」— 一張資料表，只描述一種實體（Entity）。

| 實體 | 建議的資料表 | 不應混入的資料 |
| --- | --- | --- |
| 顧客 | `customers` | 訂單明細、商品資訊 |
| 訂單 | `orders` | 顧客詳細資料 |
| 商品 | `products` | 庫存數量（應另建 `inventory`）|
| 員工 | `employees` | 部門預算、薪資等級資料 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>設計時問自己：</b>「這張表是在描述什麼？」如果答案有兩個，就考慮拆分。
</div>

<!--
第一個原則是「單一職責」，也就是「一張資料表，只描述一種實體」。

就像衣櫃裡襪子一格、上衣一格，找東西時一眼就知道要去哪裡。資料表也一樣，`customers` 只存顧客的基本資料，不存他買了什麼。`orders` 只存訂單，要看顧客詳細資料，就用 `customer_id` 回到 `customers` 去查。

表格最右邊那欄列出不應該混進來的資料。例如商品的庫存數量變動很頻繁，比較適合另外建一張 `inventory` 表。

設計時可以問自己一句話：「這張表是在描述什麼？」如果答案有兩個，就該考慮拆開了。
-->

---

# 原則二：什麼是 PRIMARY KEY？

「PRIMARY KEY 的作用，就是確保每一筆資料在表中都有唯一的識別碼。」

| 特性 | 說明 |
| --- | --- |
| **唯一性** | 每一筆資料的 PRIMARY KEY 值都不同 |
| **非空性** | PRIMARY KEY 欄位不能是 NULL |
| **穩定性** | 主鍵值不應該頻繁變動 |
| **簡單性** | 建議使用 `INT AUTO_INCREMENT`，簡單有效 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>最佳實踐：</b>大多數情況下，用 <code>id INT AUTO_INCREMENT PRIMARY KEY</code> 是最穩定的選擇。
</div>

<!--
每張表都需要一個方法，分辨誰是誰。這就是 PRIMARY KEY 的工作。

「PRIMARY KEY 的作用，就是確保每一筆資料在表中都有唯一的識別碼。」就像我們每個人的身分證字號，或是便利商店收據上的編號，不會有兩個一樣的。

那為什麼不用姓名或電話當主鍵呢？因為姓名會有同名同姓，電話也可能換。主鍵要符合表格裡的四個特性：唯一、不能是 NULL、穩定、簡單。

所以大多數情況下，用一個自動遞增的整數 `id` 當主鍵，是最穩定的選擇。
-->

---

# 原則二：PRIMARY KEY 的語法結構

```sql
-- 方式一：行內定義（最常用）
CREATE TABLE customers (
  id         INT AUTO_INCREMENT,
  name       VARCHAR(100) NOT NULL,
  email      VARCHAR(100) NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 方式二：複合主鍵（多欄位組成唯一識別）
CREATE TABLE order_items (
  order_id   INT NOT NULL,
  product_id INT NOT NULL,
  quantity   INT NOT NULL,
  PRIMARY KEY (order_id, product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

<!--
這頁是 PRIMARY KEY 的兩種寫法。

第一個範例是最常見的做法。`id` 設成 `INT AUTO_INCREMENT`，最後用 `PRIMARY KEY (id)` 指定它是主鍵。之後每新增一筆顧客，MySQL 會自動幫我們把編號往上加，不用自己指定。

第二個範例叫做「複合主鍵」。`order_items` 記錄每筆訂單裡買了哪些商品，同一筆訂單會有好幾個商品，所以單看 `order_id` 不夠，要把 `order_id` 和 `product_id` 合在一起，才能唯一識別一筆資料。

兩段執行後，會建好兩張帶主鍵的表。複合主鍵在這種中間表很好用，不過一般的資料表，還是用單一整數 id 比較簡單、好維護。
-->

---

# 原則三：FOREIGN KEY 與參照完整性

「FOREIGN KEY 的作用，就是讓兩張資料表之間建立合法的關聯。」

| 概念 | 說明 |
| --- | --- |
| **參照完整性** | 子表的外鍵值，必須在父表中存在 |
| **REFERENCES** | 指定參照哪張表的哪個欄位 |
| **ON DELETE** | 父表資料被刪除時，子表的對應行為 |
| **ON UPDATE** | 父表主鍵被更新時，子表的對應行為 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>直覺說明：</b>訂單表裡的 customer_id = 5，代表這筆訂單屬於顧客 #5。FOREIGN KEY 確保顧客 #5 真的存在，不允許「指向不存在的顧客」。
</div>

<!--
有了主鍵之後，下一個問題是：兩張表之間的關聯，要怎麼確保是合法的？

想像訂單表裡有一筆訂單，`customer_id` 是 999，可是顧客表裡根本沒有 999 號顧客。這筆訂單就變成了「孤兒資料」，指向一個不存在的人。

「FOREIGN KEY 的作用，就是讓兩張資料表之間建立合法的關聯。」加上外鍵後，新增訂單時 MySQL 會先去顧客表檢查，找不到這個顧客就直接拒絕。

這個保證就叫做「參照完整性」。表格裡的 `ON DELETE` 和 `ON UPDATE`，則是決定父表資料被刪除或修改時，子表要怎麼跟著處理。
-->

---

# 原則三：FOREIGN KEY 範例

建立 `orders` 表，並讓 `customer_id` 參照 `customers` 表：

```sql
CREATE TABLE customers (
  id   INT AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE orders (
  id          INT AUTO_INCREMENT,
  customer_id INT NOT NULL,
  total       DECIMAL(10,2) NOT NULL,
  order_date  DATE NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (customer_id) REFERENCES customers(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

<!--
我們來看外鍵的完整寫法，目標是讓訂單一定屬於某個存在的顧客。

第一個重點是建立順序。`customers` 要先建，因為 `orders` 要參照它，被參照的表必須先存在。

第二個重點是 `FOREIGN KEY (customer_id) REFERENCES customers(id)` 這一行。它的意思是，訂單的 `customer_id` 一定要對得到顧客表裡的某個 `id`。

下面的 `ON DELETE RESTRICT` 表示，顧客還有訂單時，不能刪除這個顧客。`ON UPDATE CASCADE` 表示顧客的 id 改了，訂單會自動跟著改。

執行後，如果我們新增一筆不存在顧客的訂單，MySQL 會直接報錯。另外要提醒，外鍵只有在 InnoDB 引擎下才有效，MyISAM 是不支援的。
-->

---

# 原則四：資料型別選擇原則

選擇正確的型別，影響儲存效率和查詢效能。

| 資料種類 | 建議型別 | 說明 |
| --- | --- | --- |
| 整數 ID | `INT AUTO_INCREMENT` | 最穩定的主鍵選擇 |
| 金額 | `DECIMAL(10,2)` | 避免浮點數精度誤差 |
| 姓名、標題 | `VARCHAR(100)` | 可變長度，節省空間 |
| 長文字 | `TEXT` | 超過 255 字元的內容 |
| 日期 | `DATE` / `DATETIME` | 依需求選擇 |
| 布林值 | `TINYINT(1)` | MySQL 無原生 BOOLEAN 型別 |
| 字元集 | `CHARSET=utf8mb4` | 支援中文及 emoji |

<!--
資料型別看起來是小事，選錯了卻會出大問題。表格裡列了常見資料該用的型別，我們挑兩個最容易踩坑的來講。

第一個是金額。很多人用 FLOAT 存錢，但浮點數有精度誤差，零點一加零點二，可能算出一個後面拖著一長串小數的數字。所以金額一定要用 `DECIMAL`，精確到分。

第二個是字元集。MySQL 的 `utf8` 其實只支援三個位元組的字元，存不了 emoji。所以要用 `utf8mb4`。MySQL 8 的預設已經是 `utf8mb4` 了，不過維護舊專案的時候，還是要特別留意。
-->

---

# 原則五：NULL 的使用注意事項

「NULL 代表『未知』，而不是空字串或零。」

| 情境 | 建議 |
| --- | --- |
| 必填欄位 | 加上 `NOT NULL` 約束 |
| 選填欄位（可以不填）| 允許 NULL |
| 比較 NULL | 用 `IS NULL` / `IS NOT NULL` |
| 運算含 NULL | 任何值和 NULL 運算，結果都是 NULL |

```sql
-- 錯誤寫法（永遠找不到任何資料）
SELECT * FROM customers WHERE phone = NULL;

-- 正確寫法
SELECT * FROM customers WHERE phone IS NULL;
```

<!--
NULL 是資料庫裡最容易踩坑的地方之一。

「NULL 代表『未知』，而不是空字串或零。」就像問卷上沒填的欄位，不代表答案是零，而是我們不知道答案。

最常見的錯誤就在下面的程式碼。第一段寫 `phone = NULL`，執行後永遠查不到任何資料，因為 NULL 跟任何值比較都不會成立，連跟自己比也一樣。正確寫法是第二段的 `IS NULL`，執行後就能找出沒有填電話的顧客。

另外，任何值和 NULL 運算，結果也都是 NULL。所以設計時，必填的欄位就加上 `NOT NULL`，減少不確定性。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第三部分
# 命名與慣例

<!--
最後一部分，我們來聊命名。好的命名能讓資料庫「說人話」，團隊一看就懂。
-->

---

# 資料表命名規則

| 規則 | 說明 | 範例 |
| --- | --- | --- |
| 使用小寫 snake_case | 避免大小寫敏感問題 | `order_items`, `user_profiles` |
| 使用複數名詞 | 一張表代表一個實體的集合 | `customers`, `products` |
| 避免縮寫 | 寫清楚，不要讓人猜 | `customers` 不是 `cust` |
| 避免 MySQL 保留字 | 保留字當表名需加反引號 | 不要用 `order`、`group`、`select` |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>常見錯誤：</b>用 <code>tbl_customers</code>、<code>T_CUSTOMERS</code>、<code>CustomersTBL</code> 加前後綴的寫法。這些都是不必要的，讓名稱更難讀。
</div>

<!--
命名沒有絕對的對錯，但業界有幾個普遍接受的慣例。最重要的是一致，整個資料庫都用同一套風格。

表名用小寫的 snake_case，用複數名詞，因為一張表存的是一群顧客，不是一個。名稱也要寫完整，`customers` 比 `cust` 清楚多了。

特別要注意保留字。`order` 是 MySQL 的關鍵字，拿它當表名，每次查詢都得加反引號，很麻煩。改成 `orders` 就沒有這個問題。

至於 `tbl_` 這類前綴，其實是多餘的，只會讓名稱更難讀。
-->

---

# 欄位命名規則

| 規則 | 說明 | 範例 |
| --- | --- | --- |
| 使用小寫 snake_case | 一致性 | `first_name`, `order_date` |
| 主鍵統一命名為 `id` | 保持一致 | `id`（在 customers 表）|
| 外鍵使用「被參照表單數_id」| 清楚表達關聯 | `customer_id`, `product_id` |
| 布林欄位用 `is_` 前綴 | 表達 true/false 語意 | `is_active`, `is_deleted` |
| 時間欄位加語意後綴 | 表達時間語意 | `created_at`, `updated_at` |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>一致的外鍵命名：</b>如果 orders 表參照 customers 表，外鍵就叫 <code>customer_id</code>，讓人一看就知道這是 customers 表的 ID。
</div>

<!--
表名講完，接著看欄位，目標是讓人一看就知道這個欄位存什麼。

主鍵統一叫 `id`。外鍵最容易亂取名，有人取 `uid`、`cid`，甚至 `fk_1`，看了完全不知道指向哪裡。比較好的做法是「被參照表名的單數，加上底線 id」，例如 `customer_id`，一看就知道它指向 `customers`。

布林欄位加 `is_` 開頭，像 `is_active`，讀起來就是一個是非題。時間欄位則用 `created_at`、`updated_at` 這類後綴，清楚表達是什麼時候。
-->

---

# 常見命名錯誤示範

壞的命名 vs 好的命名：

| 壞的寫法 | 好的寫法 | 問題說明 |
| --- | --- | --- |
| `tbl_customers` | `customers` | 前綴 `tbl_` 是多餘的 |
| `CustomerData` | `customers` | 大寫不一致，難以維護 |
| `cust`, `usr` | `customers`, `users` | 縮寫讓人猜意思 |
| `col1`, `data2` | `name`, `price` | 完全沒有語意 |
| `order` | `orders` | 與 MySQL 保留字衝突 |
| `utf8` | `utf8mb4` | 不支援 emoji 及 4-byte 字元 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>原則：</b>好的名稱讓你三個月後看到，不需要思考就知道它存的是什麼。
</div>

<!--
這張表把常見的命名錯誤和修正版排在一起。有人會想，名字取得怪一點，功能還是正常啊，為什麼要在乎？

因為資料庫是團隊一起用，而且會用很多年。今天我們知道 `cust` 是顧客，半年後新來的同事呢？三年後換了維護的人呢？`col1`、`data2` 這種名字，更是完全沒有線索。

所以這裡的原則是，好的名稱要讓我們三個月後再看到，不用思考就知道它存的是什麼。這是對未來的自己，也是對團隊的體貼。
-->

---

# 總結

本章學了資料庫設計的核心概念：

- **設計目標** — 減少冗餘、確保一致性、維護完整性
- **單一職責** — 一張表只描述一種實體，不同的事情拆成不同的表
- **PRIMARY KEY** — 每張表都要有主鍵，建議用 `id INT AUTO_INCREMENT`
- **FOREIGN KEY** — 建立表之間的合法關聯，保證參照完整性
- **資料型別** — 金額用 DECIMAL、字元集用 utf8mb4、避免浮點數
- **NULL** — 代表未知，比較時用 `IS NULL` 而非 `= NULL`
- **命名慣例** — 小寫 snake_case、複數表名、語意清楚的欄位名

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
🚀 <b>下一章：</b>我們將學習資料庫正規化（Normalization），深入了解如何系統性地消除資料冗餘！
</div>

<!--
我們來回顧這一章的重點。設計的目標是減少冗餘、確保資料一致。每張表只描述一件事，用 PRIMARY KEY 讓每筆資料有唯一身分，用 FOREIGN KEY 確保表之間的關聯合法。型別上，金額用 `DECIMAL`、字元集用 `utf8mb4`。NULL 代表未知，比較時要用 `IS NULL`。最後，命名保持小寫、複數、語意清楚。

下一章的正規化，會用更有系統的方法延續這些概念。在那之前，我們先用兩題練習把今天學的東西練熟。
-->

---
layout: default
---

# 練習 1：任務說明
### 設計一個書店資料庫

你要設計一個書店系統的資料庫，需要記錄以下資訊：

- 書籍資料（書名、ISBN、價格、出版日期）
- 作者資料（姓名、國籍）
- 一本書只有一個主要作者；一個作者可以寫多本書

**任務：**
1. 設計 `authors` 和 `books` 兩張資料表，定義適當的欄位和型別
2. 設定 PRIMARY KEY 和 FOREIGN KEY
3. 套用正確的命名慣例與資料型別

<!--
第一題，我們來設計一個書店資料庫。要記錄書籍和作者，而且一本書只有一個主要作者，一個作者可以寫很多本書。

請設計 `authors` 和 `books` 兩張表，設好主鍵、外鍵、型別，也套用今天的命名慣例。

這裡有一個關鍵問題：作者和書是一對多的關係，那外鍵應該放在哪一張表？我們先暫停一下，可以先在紙上畫出兩張表，再動手寫 SQL。

【講師】給大家五到十分鐘動手，可以巡堂看看外鍵放在哪一邊。
-->

---
layout: default
---

# 練習 1：解題提示

```sql
CREATE TABLE authors (
  id          INT AUTO_INCREMENT,
  name        VARCHAR(100) NOT NULL,
  nationality VARCHAR(50),
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE books (
  id           INT AUTO_INCREMENT,
  title        VARCHAR(200) NOT NULL,
  isbn         VARCHAR(20) UNIQUE,
  price        DECIMAL(8,2) NOT NULL,
  publish_date DATE,
  author_id    INT NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (author_id) REFERENCES authors(id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

<!--
我們來看解答，順便回答剛才的問題。外鍵要放在「多」的那一方，所以是 `books` 裡放一個 `author_id`。

建立順序上，`authors` 要先建，因為 `books` 要參照它。`isbn` 加了 `UNIQUE`，確保每本書的 ISBN 不會重複。價格用 `DECIMAL`，字元集用 `utf8mb4`，都是今天講過的原則。

`ON DELETE RESTRICT` 的意思是，作者還有書的時候，不能刪除這個作者。

最常見的錯誤，是在 `books` 裡直接存作者的名字，而不是 `author_id`。這樣一來，又回到資料冗餘的老問題了。
-->

---
layout: default
---

# 練習 2：任務說明
### 找出命名問題

以下 CREATE TABLE 有多個違反命名慣例的地方，請找出來並改寫：

```sql
CREATE TABLE tbl_OrderData (
  OrderID     INT AUTO_INCREMENT PRIMARY KEY,
  CustName    VARCHAR(100),
  amt         DECIMAL(10,2),
  dt          DATE,
  Active      TINYINT(1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

**任務：** 找出所有問題，並改寫成符合命名慣例的版本。

<!--
第二題是找碴題。畫面上這段 `CREATE TABLE` 能正常執行，可是違反了好幾個命名慣例。

請大家找出所有問題，再改寫成符合慣例的版本。可以從三個方向檢查：表名有幾個問題？每個欄位名稱有沒有問題？最後一行的字元集對不對？

我們先暫停一下，自己數數看總共有幾個問題。

【講師】給大家三到五分鐘，可以先請同學喊出找到幾個。
-->

---
layout: default
---

# 練習 2：解題提示

| 原始寫法 | 問題 | 修正後 |
| --- | --- | --- |
| `tbl_OrderData` | 多餘前綴 + 大寫 + 單數 | `orders` |
| `OrderID` | 大寫，應用 snake_case | `id` |
| `CustName` | 大寫 + 縮寫 | `customer_name` |
| `amt` | 縮寫，語意不清 | `amount` |
| `dt` | 縮寫，語意不清 | `order_date` |
| `Active` | 大寫 + 缺少 `is_` 前綴 | `is_active` |
| `utf8` | 應使用 utf8mb4 | `utf8mb4` |

<!--
答案是七個問題。

表名 `tbl_OrderData` 一次犯了三個錯：多餘的前綴、用了大寫、還是單數，改成 `orders` 就好。欄位方面，`OrderID` 和 `CustName` 用了大寫和縮寫。`amt`、`dt` 縮寫到看不出意思，改成 `amount` 和 `order_date`。`Active` 則少了 `is_` 開頭。

最後是字元集，`utf8` 只支援三個位元組，存不了 emoji，要改成 `utf8mb4`。

大家都找到七個了嗎？這些都是實際專案裡很常見的錯誤，現在練熟，以後就不會犯了。
-->

---
layout: end
---

# Q & A

有任何問題嗎？

<!--
今天我們從壞設計的問題出發，學了單一職責、主鍵、外鍵、資料型別和 NULL 這五個原則，也整理了一套命名慣例。

好的設計習慣要從一開始就養成，不要等資料庫變大了才回頭修，那時候的代價會高很多。

這一章就到這裡，我們下一章正規化見。

【講師】開放提問，可以從主鍵、外鍵設定或命名慣例引導大家發問。
-->
