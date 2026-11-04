---
theme: penguin
class: text-center
highlighter: shiki
lineNumbers: true
drawings:
  persist: false
transition: slide-left
title: Index 索引與 Execution Plan
routeAlias: ch08
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
    Index 索引與執行計畫
  </h1>
  <div style="height: 4px; width: 320px; background: linear-gradient(90deg, #5eada0, #a7d9d0); border-radius: 2px; margin-bottom: 1.5rem;"></div>
  <p style="color: #4a7c7c; font-size: 1.15rem; font-style: italic;">
    「讀懂 MySQL 的想法，才能讓查詢跑得快」
  </p>
  <Link to="home" style="color: #9dc4c4; font-size: 0.85rem; margin-top: 2rem; text-decoration: none; letter-spacing: 0.05em;">← 返回目錄</Link>
</div>

<!--
大家好，歡迎來到第八章：Index 索引與執行計畫。

前幾章我們學會了各種查詢。不過不過有時候 SQL 明明寫對了，卻要跑好幾秒。原因通常在索引設計，以及我們不清楚 MySQL 怎麼執行這個查詢。

這一章就要解決這兩件事。學完之後，大家能用 EXPLAIN 找出查詢慢的原因，再用索引讓它變快。
-->

---
layout: default
---

# Outline

- **什麼是索引？** — 索引的原理與類比
- **索引的種類** — B-Tree、UNIQUE、FULLTEXT
- **如何建立與管理索引** — CREATE INDEX、DROP INDEX
- **什麼時候加索引？** — 適合與不適合的場景
- **EXPLAIN 入門** — 確認查詢有沒有用到索引

<!--
這一章分成前後兩半。前半段是索引，我們會先看它的原理，再認識種類、學會建立，以及判斷什麼時候該加。後半段是 EXPLAIN，用它確認查詢到底有沒有用上索引。

索引是加速的工具，EXPLAIN 是檢查的工具，兩個搭配起來，就能讓查詢跑得更快。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第一部分
# 什麼是索引？

<!--
我們先搞清楚索引是什麼，以及它為什麼能讓查詢變快。
-->

---

# 索引就是書本的目錄

「索引（Index）讓 MySQL 能夠快速定位資料，而不需要掃描整張表的每一列。」

| 沒有索引 | 有索引 |
| --- | --- |
| 全表掃描（Full Table Scan）| 直接定位到目標資料 |
| 就像在一本沒有目錄的字典裡，一頁一頁翻 | 就像用字典的目錄，直接翻到目標頁 |
| 10,000 筆資料要掃 10,000 次 | 10,000 筆資料可能只掃幾次 |
| 資料量越多，越慢 | 資料量大時，差距更明顯 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>代價：</b>索引加速 SELECT，但讓 INSERT / UPDATE / DELETE 稍微變慢（需要同時維護索引）。空間也會增加。
</div>

<!--
「索引讓 MySQL 能夠快速定位資料，而不需要掃描整張表的每一列。」

最好的比喻就是字典的目錄。想像一本一千頁、沒有目錄的字典，要找 MySQL 這個詞，只能從第一頁開始一頁一頁翻。有了目錄，查一下就知道 M 開頭的詞在第五百頁之後，直接翻過去就好。

資料表也一樣。沒有索引時，查名字是 Alice 的資料，MySQL 得把整張表掃一遍，這叫全表掃描。有了名字的索引，就能直接定位到 Alice。資料越多，差距越明顯。

不過索引也有代價。它本身要佔空間，而且每次新增、修改、刪除資料，都得同時更新索引。所以索引不是越多越好。
-->

---

# 索引的種類

MySQL 支援多種索引類型，每種有不同的適用場景：

| 索引類型 | 說明 | 適用場景 |
| --- | --- | --- |
| **B-Tree（預設）** | 最常用的索引類型，支援範圍查詢 | 大多數 WHERE、ORDER BY、JOIN |
| **UNIQUE** | 值不重複的索引，同時有加速效果 | email、ISBN 等唯一欄位 |
| **PRIMARY KEY** | 特殊的 UNIQUE 索引，不允許 NULL | 主鍵欄位（自動建立）|
| **FULLTEXT** | 全文搜尋索引 | 長文字的關鍵字搜尋 |
| **複合索引** | 多個欄位組成的索引 | 常常同時用多個欄位篩選的查詢 |

<!--
表格列出了 MySQL 常見的索引種類。

最常用的是 B-Tree，大多數情況不用特別指定，預設就是它。它能處理等於、範圍查詢，像 BETWEEN 和大於小於，還有開頭固定的 LIKE，以及排序。

UNIQUE 索引確保值不重複，也能加速查詢。FULLTEXT 則用在長文字的關鍵字搜尋。

複合索引是由好幾個欄位組成的。它有一個重要規則，叫做「最左前綴規則」。索引如果是 a、b、c 三個欄位，查詢條件要從 a 開始才用得到。只用 b 或只用 c 查詢，這個索引就派不上用場。
-->

---

# 建立與管理索引

```sql
-- 建立一般索引
CREATE INDEX idx_category ON products (category);

-- 建立唯一索引
CREATE UNIQUE INDEX idx_sku ON products (sku);

-- 建立複合索引（注意欄位順序！）
CREATE INDEX idx_cat_price ON products (category, price);

-- 查看資料表的所有索引
SHOW INDEX FROM products;

-- 刪除索引
DROP INDEX idx_category ON products;
```

<!--
這頁是建立和管理索引的語法。

一般索引用 `CREATE INDEX`，後面接索引名稱、表名和欄位。唯一索引多加一個 `UNIQUE`。

複合索引要特別注意欄位順序。`(category, price)` 和 `(price, category)` 是兩個不同的索引。前者適合先用分類篩選、再看價格的查詢。後者適合只用價格篩選，或依價格排序的查詢。

最後兩行也很常用。`SHOW INDEX FROM products` 可以列出這張表所有的索引，`DROP INDEX` 則用來刪除不需要的索引。
-->

---

# 什麼時候加索引？

**適合加索引的欄位：**

| 場景 | 範例 |
| --- | --- |
| 常出現在 WHERE 條件的欄位 | `WHERE status = 'active'` |
| 用於 JOIN 的外鍵欄位 | `orders.customer_id` |
| 用於 ORDER BY 的欄位 | `ORDER BY created_at DESC` |
| 需要唯一性的欄位 | `email`、`sku`、`isbn` |

<!--
那麼什麼欄位適合加索引呢？表格列出了四種情況：常出現在 WHERE 條件裡的、用來 JOIN 的外鍵、用來排序的，以及需要唯一性的欄位。

判斷時還有兩件事要考慮。第一是欄位的選擇性，也就是不同的值有多少種。email 每個人都不一樣，加索引效果很好。是否上架只有零和一，加了幫助不大。

第二是這張表寫入有多頻繁。寫入越頻繁，每多一個索引，新增和修改就慢一點。

所以加索引之前，要先看實際的查詢模式。
-->

---
layout: default
---

# 什麼時候加索引？（續）

**不適合加索引的欄位：**

| 場景 | 原因 |
| --- | --- |
| 選擇性低的欄位（如 is_active）| 只有 0/1 兩種值，索引沒有意義 |
| 頻繁 INSERT / UPDATE 的小表 | 索引維護成本高於收益 |
| 已被其他索引涵蓋的欄位 | 重複建索引浪費空間 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>實務建議：</b>先觀察，再最佳化，比猜測性地預先加索引更好。
</div>

<!--
反過來，也有不適合加索引的情況。

像是否上架這種選擇性很低的欄位，只有兩種值，索引幫不上忙。很小、又經常寫入的表，維護索引的成本，可能比它帶來的好處還高。已經被其他索引涵蓋的欄位，重複建立只是浪費空間。

實務上可以這樣安排。主鍵會自動建立索引，外鍵欄位一定要有索引。其他欄位，就根據實際的查詢需求，用接下來要學的 EXPLAIN 找出問題，再決定要不要加。

也就是畫面下方那句話，「先觀察，再最佳化」，比憑感覺預先加一堆索引更好。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第二部分
# EXPLAIN 執行計畫

<!--
索引建好了，可是 MySQL 真的有用到嗎？接下來的 EXPLAIN，就是用來確認這件事的。
-->

---

# 什麼是 EXPLAIN？

「在 SELECT 前加上 EXPLAIN，MySQL 就會告訴你它打算怎麼執行這個查詢——但不會真的執行它。」

```sql
-- 一般查詢
SELECT * FROM products WHERE category = '手機';

-- 加上 EXPLAIN：查看執行計畫
EXPLAIN SELECT * FROM products WHERE category = '手機';
```

EXPLAIN 的輸出欄位很多，初學先看這兩個：

| 欄位 | 說明 | 怎麼判斷 |
| --- | --- | --- |
| `key` | 實際使用的索引 | `NULL` = 沒用到索引 |
| `rows` | 預估需要掃描的資料筆數 | 越少越好 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>警示訊號：</b><code>key</code> 是 NULL，而且 <code>rows</code> 接近整張表的筆數，代表 MySQL 正在一筆一筆翻整張表，這個查詢需要加索引。
</div>

<!--
「在 SELECT 前加上 EXPLAIN，MySQL 就會告訴你它打算怎麼執行這個查詢，但不會真的執行它。」

用法非常簡單。上面是一般查詢，下面只是在前面多加了 `EXPLAIN` 這個字。執行後，我們看到的不是商品資料，而是一份執行計畫，說明 MySQL 打算怎麼找資料。因為不會真的執行，就算是很大的表，也可以放心使用。

輸出的欄位很多，我們先看兩個就好。`key` 是實際用到的索引，顯示 NULL 就代表沒用到。`rows` 是預計要掃描幾筆資料，越少越好。

如果 key 是 NULL，rows 又接近整張表的筆數，就像在沒有目錄的字典裡一頁一頁翻。這時候，就該考慮幫查詢條件的欄位加索引了。
-->

---

# 總結

本章學了 Index 索引和 EXPLAIN 執行計畫：

- **索引原理** — 就像書本目錄，讓查詢不需要掃描整張表
- **索引種類** — B-Tree（預設）、UNIQUE、FULLTEXT、複合索引
- **何時加索引** — WHERE / JOIN / ORDER BY 的欄位；避免低選擇性欄位
- **EXPLAIN** — 在 SELECT 前加 EXPLAIN，查看執行計畫而不執行查詢
- **key 與 rows** — key 是 NULL、rows 很大，就是需要加索引的訊號

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
🚀 <b>下一章：</b>我們將學習 VIEW 視圖，學會如何把複雜的 SQL 查詢包裝成可重複使用的虛擬資料表！
</div>

<!--
我們整理這一章。索引就像書的目錄，讓查詢不用掃描整張表，複合索引要遵守最左前綴規則。索引適合加在 WHERE、JOIN、排序常用的欄位。

EXPLAIN 讓我們在不執行的情況下看到執行計畫。key 是 NULL、rows 又很大，就是需要加索引的訊號。

最好的流程是先寫出正確的查詢，再用 EXPLAIN 檢查，有針對性地加索引。接下來用兩題練習試試看。
-->

---
layout: default
---

# 練習 1：任務說明
### 分析 EXPLAIN 輸出

以下是一張有 100 萬筆資料的 `orders` 表：

```sql
-- 執行 EXPLAIN
EXPLAIN SELECT * FROM orders
WHERE customer_id = 100 AND status = 'completed'
ORDER BY order_date DESC
LIMIT 10;

-- EXPLAIN 輸出（模擬）：
-- key: NULL, rows: 1000000
```

**任務：**
1. 從 `key` 和 `rows` 說明這個查詢的效能問題
2. 提出你的索引最佳化方案（寫出 CREATE INDEX）
3. 說明加索引後 `key` 和 `rows` 預期會有什麼改變

<!--
第一題，我們來讀一份 EXPLAIN 的結果。這張訂單表有一百萬筆資料，查詢要找出某位顧客已完成的訂單，依日期由新到舊，取前十筆。

畫面上模擬了 EXPLAIN 的輸出。請大家從 key 和 rows 說明這個查詢有什麼問題，寫出要建立的索引，並預測加了索引之後，這兩個欄位會怎麼變。

思考一下，WHERE 裡有兩個條件，應該建兩個單欄位的索引，還是一個複合索引？

我們先暫停一下，自己分析看看。

【講師】給大家五到十分鐘，可以請同學先說說看 key 是 NULL 代表什麼。
-->

---
layout: default
---

# 練習 1：解題提示

**問題分析：**
- `key=NULL`：沒有用到任何索引
- `rows=1000000`：整張表 100 萬筆全部掃一遍

**最佳化方案：**

```sql
-- 建立複合索引：WHERE 用到的兩個欄位
CREATE INDEX idx_cust_status
  ON orders (customer_id, status);
```

<!--
我們先看問題分析。key 是 NULL，代表沒有任何索引可用。rows 是一百萬，等於整張表都掃過一遍，只為了找出一位顧客的十筆訂單。

最佳化方案是幫 WHERE 用到的兩個欄位，建立一個複合索引。這也回答了剛才的思考題，兩個條件常常一起出現，用一個複合索引就能同時照顧到。

欄位順序也有講究。`customer_id` 放第一個，因為每位顧客只佔全部訂單的一小部分，先用它篩選，範圍一下子就縮小了。`status` 放第二個，在這位顧客的訂單裡，再挑出已完成的。
-->

---
layout: default
---

# 練習 1：解題提示（續）

**加索引後的預期 EXPLAIN 結果：**

| 欄位 | 改善前 | 改善後（預期）|
| --- | --- | --- |
| `key` | NULL | idx_cust_status |
| `rows` | 1,000,000 | 少量（數十到數百）|

<!--
加上索引之後，EXPLAIN 預期會有這些變化。

key 會顯示我們剛建立的索引名稱，代表 MySQL 用上了它。rows 從一百萬，降到幾十到幾百筆，只需要看這位顧客已完成的訂單。

這裡再複習一次最左前綴規則。這個索引可以用在只查顧客編號，或是顧客編號加狀態的查詢。但如果只用狀態查詢，就沒辦法用到它，因為少了最左邊的顧客編號。
-->

---
layout: default
---

# 練習 2：任務說明
### 設計索引策略

有一個電商系統，常用的查詢如下：

1. 查詢某顧客的所有訂單（`WHERE customer_id = ?`）
2. 查詢特定日期範圍的訂單（`WHERE order_date BETWEEN ? AND ?`）
3. 查詢有庫存的商品，依價格排序（`WHERE stock > 0 ORDER BY price`）
4. 用商品名稱關鍵字搜尋（`WHERE name LIKE '%iPhone%'`）

**任務：**
1. 為每個查詢提出對應的索引方案
2. 說明哪個查詢即使加了索引也不會有效果，以及原因

<!--
第二題是設計索引策略。畫面上列出了一個電商系統最常用的四個查詢。

請大家幫每個查詢提出對應的索引方案，並且找出哪一個查詢就算加了索引也沒有效果，說明原因。

這裡給一個思考方向。第四個查詢的 LIKE，前面多了一個百分比符號，想想看字典的目錄，還幫得上忙嗎？

我們先暫停一下，自己想想看。

【講師】給大家五到十分鐘，可以先討論第四題為什麼特別。
-->

---
layout: default
---

# 練習 2：解題提示

| 查詢 | 索引方案 | 說明 |
| --- | --- | --- |
| `WHERE customer_id = ?` | `INDEX (customer_id)` | 外鍵欄位，標準索引 |
| `WHERE order_date BETWEEN ? AND ?` | `INDEX (order_date)` | 範圍查詢，B-Tree 索引有效 |
| `WHERE stock > 0 ORDER BY price` | `INDEX (price)` | 排序欄位加索引，依價格順序讀取 |
| `WHERE name LIKE '%iPhone%'` | ❌ B-Tree 索引無效 | 前導 % 無法使用索引 |

**LIKE '%xxx%' 的替代方案：**

```sql
-- 方案一：改用 FULLTEXT 索引（支援全文搜尋）
ALTER TABLE products ADD FULLTEXT INDEX ft_name (name);
SELECT * FROM products WHERE MATCH(name) AGAINST('iPhone');

-- 方案二：改用前綴搜尋 LIKE 'xxx%'（可使用 B-Tree 索引）
SELECT * FROM products WHERE name LIKE 'iPhone%';
```

<!--
我們來看解答。前兩個查詢很單純，顧客編號是外鍵，加一般索引就好。日期範圍查詢，B-Tree 索引也能處理。

第三個查詢，大部分商品都有庫存，用庫存篩選效果有限，反而是排序比較吃力。所以幫價格加索引，索引裡的價格本來就排好了，MySQL 照順序讀就好。

第四個查詢加了索引也沒用。這就像字典的目錄是依字首排列的，要找「中間包含某個字」的詞，目錄幫不上忙，只能整本翻。

替代方案有兩個。一是改用 FULLTEXT 索引，搭配 `MATCH AGAINST` 做全文搜尋。二是改成 `LIKE 'iPhone%'`，就能用 B-Tree 索引，不過意思變成以 iPhone 開頭，跟包含 iPhone 不完全一樣。

如果需要更強的搜尋，實務上通常會引入 Elasticsearch 這類專門的搜尋引擎。
-->

---
layout: end
---

# Q & A

有任何問題嗎？

<!--
今天我們學會了兩個工具。索引讓查詢變快，EXPLAIN 讓我們確認索引有沒有用上。最重要的兩個觀念是：看到 key 是 NULL、rows 又很大，就要考慮加索引；複合索引的欄位順序很重要，要遵守最左前綴規則。

下一章，我們要學 VIEW 視圖，把複雜的查詢包裝成可以重複使用的虛擬資料表。我們下一章見。

【講師】開放提問，可以請同學挑一個自己寫過的查詢，現場用 EXPLAIN 看看。
-->
