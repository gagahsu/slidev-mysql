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
大家好，歡迎來到 MySQL 資料庫課程的第一章！

在我們正式開始學習 SQL 查詢之前，我想先跟大家聊一個很多人會忽略的話題：「如何設計一個好的資料庫」。

很多人急著學 SELECT、JOIN，卻忽略了資料表設計。但好的設計才是一切的基礎——設計不好，查詢就會又慢又麻煩。

今天，我們就來學習那些讓資料庫工程師奉行不悖的設計原則。
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
這章的架構很清楚。

我們先從「為什麼要設計」說起，了解設計不好會帶來什麼問題。

接著進入五個核心原則，這些都是業界工程師天天用到的設計基礎。

最後聊聊命名規則——這是很多教材跳過，但在實際工作中非常重要的主題。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第一部分
# 什麼是關聯式資料庫設計？

<!--
進入第一部分，我們先說說「什麼是資料庫設計」，以及為什麼它這麼重要。

這部分很概念性，但我保證用生活例子讓大家很快就懂。
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
想像你開了一家餐廳，需要記錄每筆訂單。

如果你用一本紙本記事本，每次訂單你都把客戶的姓名、電話、地址重新寫一遍——這很花時間，而且客戶改電話時，你要把所有訂單都改一遍，很容易改漏。

這就是「資料冗餘」帶來的問題。好的資料庫設計，就是要解決這些問題：讓同一份資料只存一次，讓改動只需要改一個地方。
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
左邊是壞設計：一張超大的訂單表，把所有東西都塞在一起。右邊是好設計：客戶表只存客戶資料，訂單表只存訂單資料，兩者用 customer_id 連接。

好設計不只是「整齊」，它解決了實際的維護問題。當客戶電話改變時，好設計只需要改一筆資料；壞設計可能要改幾千筆。

⚠️ 「把不同的事情存在不同的表」這個概念，就是下一章「正規化」的基礎。
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
看這段 CREATE TABLE，大家能感覺到問題在哪裡嗎？

這張表把客戶資訊（name、phone、email）和訂單資訊（product、price、quantity）全部混在一起。

當客戶 Alice 下了 100 筆訂單，customer_name = 'Alice'、customer_phone 就重複了 100 次。這不只浪費空間，更重要的是：Alice 換了電話，你要更新哪些資料？全部 100 筆！而且可能改到一半就出錯了。

這就是「資料冗餘」和「更新異常」。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第二部分
# 核心設計原則

<!--
知道了壞設計的問題，接下來我們來說五個核心設計原則。

這五個原則看起來基礎，但幾乎所有好的資料庫設計都遵循它們。大家把它們記起來，以後設計資料表的時候就有依據了。
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
第一個原則是「單一職責」。

簡單說就是：一張表只負責一件事。`customers` 表只存顧客的基本資料，不存他下了什麼訂單。`orders` 表只存訂單資料，顧客的詳細資料用 `customer_id` 去 `customers` 表查。

好處是：每張表的職責清楚，維護起來也更容易。當你需要修改顧客資料，你知道去哪裡找；當你需要查訂單記錄，你也知道去哪裡查。
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
PRIMARY KEY 就是資料表的「身份證號碼」。

想一下你去便利商店買東西，收據上有一個訂單編號。這個編號是唯一的，不會有兩張收據有相同的號碼。PRIMARY KEY 的作用就是這樣：讓每一筆資料都有一個獨一無二的識別碼。

為什麼不用名字、電話當主鍵？因為名字可以重複（同名同姓），電話也可能變動。用一個自動遞增的整數 ID，既不重複、也不變動，是最穩定的選擇。
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
看這兩個範例。

第一個是最常見的寫法：用 id INT AUTO_INCREMENT 作為主鍵。每次插入新資料，MySQL 會自動幫你遞增這個 ID，不需要手動指定。

第二個是複合主鍵的例子。`order_items` 表記錄每筆訂單的每個商品，一筆訂單可以有多個商品，所以用 (order_id, product_id) 的組合來唯一識別每一筆資料。

⚠️ 注意：複合主鍵雖然有時有用，但大多數情況下單一整數 ID 更簡單、更容易維護。
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
FOREIGN KEY 解決的問題是：「如何確保兩張表之間的資料是合法的？」

想像訂單表裡有一筆 customer_id = 999 的訂單，但顧客表裡根本沒有 ID = 999 的顧客。這筆資料就是「孤兒資料」——它參照了一個不存在的顧客，邏輯上是不合理的。

FOREIGN KEY 就是用來防止這種情況。當你試圖插入一筆 customer_id = 999 的訂單時，MySQL 會自動檢查顧客表裡有沒有 id = 999，如果沒有就拒絕操作。

這就是「參照完整性」的保證。
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
這是一個完整的兩張表關聯範例。

customers 表先建立，因為 orders 表需要參照它。這個順序很重要：被參照的表必須先存在。

FOREIGN KEY (customer_id) REFERENCES customers(id) 告訴 MySQL：orders 表的 customer_id 欄位，必須對應到 customers 表的 id 欄位。

ON DELETE RESTRICT：如果嘗試刪除一個還有訂單的顧客，MySQL 會拒絕這個操作，保護資料不被意外刪除。

⚠️ 注意：MySQL 的 FOREIGN KEY 只在 InnoDB 引擎下才有效，MyISAM 不支援外鍵約束。
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
資料型別的選擇看起來是小事，但影響很大。

最常見的錯誤是用 FLOAT 來存金額。FLOAT 是浮點數，有精度問題，計算 0.1 + 0.2 可能得到 0.30000000000000004 這樣的結果。金額一定要用 DECIMAL，精確到分。

另一個常見錯誤是用 utf8 而不是 utf8mb4。MySQL 的 utf8 其實只支援 3 byte 的字元，無法存 emoji 等 4 byte 字元。

⚠️ MySQL 8.x 的預設字元集已改為 utf8mb4，但舊版專案可能還是 utf8（utf8mb3），需要特別注意。
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
NULL 是資料庫設計中很容易踩到的坑。

NULL 不是空字串 ''，也不是數字 0，它代表「這個資料是未知的」。

最常見的錯誤是用 = NULL 來查詢。WHERE phone = NULL 永遠找不到任何資料，因為 NULL 不等於任何值（包括它自己）。正確寫法是 IS NULL。

建議：能加 NOT NULL 的欄位就加，減少 NULL 帶來的不確定性。聚合函式（COUNT、SUM）遇到 NULL 的行為也要特別注意。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第三部分
# 命名與慣例

<!--
最後一個部分，我們來聊聊命名規則。

這個主題在教科書裡通常只有一頁，但在實際工作中，好的命名習慣能讓你的資料庫「說人話」，讓團隊裡的每個人一看就懂。
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
命名規則沒有絕對的對錯，但有幾個業界普遍接受的慣例。最重要的是一致性：整個資料庫都用同一套命名風格。

複數名詞的慣例（customers 而不是 customer）是因為一張表存的是「多個」顧客的資料集合，用複數更直觀。

⚠️ 特別注意保留字的問題。`order` 是 MySQL 的關鍵字，如果你用 `order` 當表名，每次查詢都要加反引號，非常麻煩。改用 `orders` 就沒這個問題。
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
欄位命名的目標是「讓人一看就懂這個欄位存的是什麼」。

外鍵命名是最容易出錯的地方。我看過有人在 orders 表裡把參照 customers 的外鍵命名為 uid、cid、fk_1 等等，讓人完全看不懂這個欄位是什麼意思。

統一使用「被參照表名的單數 + _id」的格式，例如 customer_id、product_id，讓人一看就知道這個欄位指向哪張表。
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
大家可能覺得：這些只是命名問題，不影響功能，為什麼要在乎？

答案是：資料庫設計是團隊合作的，也是跨時間的工作。今天你知道 cust 代表 customers，但六個月後新來的同事呢？三年後換了個維護人員呢？

好的命名是對未來的自己和團隊的尊重。
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
學完這章，大家應該對「怎樣才是好的資料庫設計」有了基本的感覺。

這些原則不是憑空想出來的，都是業界工程師從無數次的痛苦維護經驗中總結出來的。

下一章我們會更深入地探討正規化，那是一套更系統性的設計方法，會讓今天的概念更加具體化。

現在先做兩題練習，把今天學到的東西鞏固一下！
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
這題考驗大家是否理解「一對多關聯」以及如何用 PRIMARY KEY 和 FOREIGN KEY 表達它。

一個作者可以寫多本書，所以 authors 和 books 是一對多的關係。

外鍵應該放在「多」的那一方，也就是 books 表裡放 author_id。

大家試著先在紙上畫出來，再用 SQL 寫出來。
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
看解答的重點：

1. authors 表先建立，因為 books 要參照它。建立順序很重要！

2. isbn 加了 UNIQUE 約束，確保每本書的 ISBN 不重複。

3. FOREIGN KEY (author_id) REFERENCES authors(id)：books 表的 author_id 指向 authors 表的 id。

4. ON DELETE RESTRICT：如果作者還有書，就不能刪除這個作者。這保護了資料的完整性。

⚠️ 大家容易犯的錯：在 books 表裡存作者的名字而不是 author_id。這樣就回到了「資料冗餘」的老問題。
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
這題是找碴題，考驗大家對今天學的命名慣例的理解。

大家可以先自己找找看，有幾個問題？

提示：表名、欄位名各有幾個問題？字元集有沒有問題？
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
這七個問題都是實際專案中常見的命名錯誤。

特別是 utf8 vs utf8mb4 的問題很重要。MySQL 的 utf8 其實是 utf8mb3，只支援 3 byte 的字元，無法存 emoji 或某些特殊字元。

⚠️ MySQL 8.x 已將預設字元集改為 utf8mb4，但如果你還在維護舊的資料庫，要特別注意這個問題。

大家有沒有全部找到七個問題？
-->

---
layout: end
---

# Q & A

有任何問題嗎？

<!--
現在開放 Q&A 時間。

大家對今天的資料庫設計原則有沒有什麼疑問？

無論是 PRIMARY KEY 的用法、FOREIGN KEY 的設定，還是命名慣例，都歡迎提問。

記住：好的設計習慣要從一開始就養成，不要等到資料庫龐大了再來修正！
-->
