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
### 分析前台問卷列表的 EXPLAIN

問卷系統上線一段時間後，`surveys` 累積了 20 萬筆資料，前台列表越來越慢：

```sql
EXPLAIN SELECT id, title, end_date
FROM surveys
WHERE published = 1
  AND CURDATE() BETWEEN start_date AND end_date
ORDER BY end_date
LIMIT 10;
-- key: NULL, rows: 199396
```

**任務：**
1. 從 `key` 和 `rows` 說明這個查詢的效能問題
2. 提出你的索引方案（寫出 CREATE INDEX）
3. 說明加索引後 `key` 和 `rows` 預期會有什麼改變

<!--
第一題，我們來讀一份 EXPLAIN 的結果。這是在二十萬筆問卷資料上實際跑出來的，查詢要找出進行中的問卷，取最快結束的前十筆。

請大家從 key 和 rows 說明問題在哪裡，寫出要建立的索引，並預測這兩個欄位會怎麼變。

思考一下，索引要放哪些欄位？`published` 是等於，`end_date` 除了篩選還要排序，順序該怎麼排？

我們先暫停一下，自己分析看看。

【講師】給大家五到十分鐘，可以請同學先說說 key 是 NULL 代表什麼。
-->

---
layout: default
---

# 練習 1：解題提示

**問題分析：**
- `key=NULL`：沒有用到任何索引
- `rows=199396`：幾乎把整張表都掃過一遍

**最佳化方案：**

```sql
-- 等於條件放前面，範圍條件兼排序的欄位放後面
CREATE INDEX idx_pub_end ON surveys (published, end_date);
```

<!--
key 是 NULL，代表沒有索引可用。rows 將近二十萬，等於整張表都掃過一遍，只為了找十筆資料。

最佳化方案是複合索引。這也回答了剛才的思考題，`published` 是等於條件，放第一個。`end_date` 同時用來篩選和排序，放第二個。

這樣 MySQL 先找到已發佈的問卷，再依結束日期的順序往下讀，讀滿十筆符合條件的資料就能停下來。

`start_date` 留給 WHERE 再檢查一次就好。
-->

---
layout: default
---

# 練習 1：解題提示（續）

**加索引後實際的 EXPLAIN 結果：**

| 欄位 | 改善前 | 改善後 |
| --- | --- | --- |
| `key` | NULL | idx_pub_end |
| `rows`（預估） | 199,396 | 2,304 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>最左前綴規則：</b><code>(published, end_date)</code> 可用於 <code>WHERE published = ?</code> 與 <code>WHERE published = ? AND end_date …</code>，但單獨查 <code>end_date</code> 用不到這個索引。
</div>

<!--
加上索引之後，key 顯示我們剛建立的索引，rows 從將近二十萬，降到兩千多筆。

rows 是 MySQL 的預估值，不同的資料分布結果會不一樣，重點是看它大幅下降了。

這裡再複習一次最左前綴規則。這個索引可以用在只查 `published`，或是同時查 `published` 和 `end_date` 的查詢。但如果只查 `end_date`，少了最左邊的欄位，就用不到它了。
-->

---
layout: default
---

# 練習 2：任務說明
### 設計問卷系統的索引策略

以下是問卷系統常用的五個查詢（資料表結構見 `sql/schema.sql`）：

1. 某份問卷的所有題目：`questions WHERE survey_id = ?`
2. 某問卷的作答列表：`survey_responses WHERE survey_id = ? ORDER BY id DESC LIMIT 10`
3. 檢查 Email 是否填過：`survey_responses WHERE survey_id = ? AND email = ?`
4. 統計某題的所有答案：`response_answers WHERE question_id = ?`
5. 標題模糊搜尋：`surveys WHERE title LIKE '%午餐%'`

**任務：**
1. 對每個查詢，說明 `schema.sql` **已經有**哪個索引可用，還是需要**新增**
2. 說明哪個查詢加了 B-Tree 索引也沒有效果，並提出替代方案

<!--
第二題要練習一個很實用的技能，先看懂資料表已經有哪些索引，再決定要不要新增。

請大家打開 `schema.sql`，對照這五個查詢。可以用 `SHOW INDEX FROM` 加上表名，看到一張表所有的索引。

思考一下，`UNIQUE` 約束除了保證不重複，它本身是不是也是一個索引？

我們先暫停一下，自己分析看看。

【講師】給大家十分鐘，可以先討論第五題為什麼特別。
-->

---
layout: default
---

# 練習 2：解題提示

| 查詢 | 索引方案 | 說明 |
| --- | --- | --- |
| 1. 問卷的題目 | ✅ 已有 `idx_questions_survey` | 外鍵欄位，建表時已建立 |
| 2. 作答列表 | ✅ 已有 `uk_survey_email` | 最左前綴可用 `survey_id` |
| 3. 檢查 Email | ✅ 已有 `uk_survey_email` | 兩個欄位完整命中 |
| 4. 某題的答案 | ✅ 已有 `idx_answers_question` | 統計頁的核心查詢 |
| 5. `LIKE '%午餐%'` | ❌ B-Tree 索引無效 | 前導 `%` 無法定位起點 |

<!--
前四個查詢，資料表都已經有索引可以用，不需要新增。這也回答了剛才的思考題，`UNIQUE` 本身就是一個索引，一舉兩得。

第二個查詢要多說一句。範例資料很少，EXPLAIN 可能顯示 MySQL 直接用主鍵。這是優化器依資料量做的判斷，不代表索引不能用。

第五個查詢前面有百分比符號，就像字典的目錄幫不上忙，只能整本翻。
-->

---
layout: default
---

# 練習 2：解題提示（續）

```sql
-- 方案一：FULLTEXT 索引（中文要指定 ngram 分詞器）
ALTER TABLE surveys
  ADD FULLTEXT INDEX ft_title (title) WITH PARSER ngram;
SELECT id, title FROM surveys
WHERE MATCH(title) AGAINST('午餐');

-- 方案二：改成前綴搜尋（只能找「以午餐開頭」）
SELECT id, title FROM surveys
WHERE title LIKE '午餐%';
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>資料量小時，直接用 LIKE 就夠了。</b>索引有維護成本，不要為了「可能會用到」就亂建。
</div>

<!--
替代方案有兩個。一是 FULLTEXT 索引。MySQL 預設的分詞方式對中文不友善，所以要指定 ngram。二是改成前綴搜尋，可以用 B-Tree 索引，不過意思變成以午餐開頭。

兩個方案在範例資料上都會查到午餐偏好調查。

不過，資料量小的時候，直接用 LIKE 就夠了。索引有維護成本，寫入時也要一起更新，所以不要為了可能會用到就亂建。
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
