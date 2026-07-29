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
大家好，歡迎來到第八章——Index 索引與執行計畫！

前幾章我們學了各種 SQL 查詢語法。但有時候你的 SQL 寫對了，卻跑得很慢——為什麼？

答案通常在兩個地方：索引（Index）的設計，以及你是否了解 MySQL 如何執行你的查詢。

這章我們要學兩件事：
1. 什麼是索引，以及如何正確地建立索引
2. 如何用 EXPLAIN 讀懂 MySQL 的「執行計畫」，找出查詢慢的根本原因
-->

---
layout: default
---

# Outline

- **什麼是索引？** — 索引的原理與類比
- **索引的種類** — B-Tree、UNIQUE、FULLTEXT
- **如何建立與管理索引** — CREATE INDEX、DROP INDEX
- **什麼時候加索引？** — 適合與不適合的場景
- **EXPLAIN 執行計畫** — 讀懂 MySQL 的執行計畫
- **EXPLAIN 欄位解讀** — type、key、rows、Extra

<!--
這章分成兩大主題：索引（前半）和 EXPLAIN（後半）。

索引是「加速查詢的工具」，EXPLAIN 是「診斷查詢問題的工具」。

兩個主題密切相關：用 EXPLAIN 找出慢查詢，再用索引解決它——這是最完整的查詢最佳化流程。

特別是 EXPLAIN 的 type 欄位，掌握了它，你就能一眼看出一個查詢是否有效率。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第一部分
# 什麼是索引？

<!--
進入第一部分，先說清楚索引是什麼，以及它為什麼能加速查詢。

有了直覺感受，後面的技術細節就好理解多了。
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
索引的最好比喻就是書本的目錄。

想像你有一本沒有目錄的字典，你想找「MySQL」這個詞，你只能從第一頁開始，一頁一頁翻，直到找到為止。如果字典有 1000 頁，最差情況你要翻 1000 頁。

有了目錄，你看一下目錄知道「M 開頭的詞在第 500 頁以後」，然後直接翻到那裡——節省了大量時間。

資料庫的索引道理一樣：沒有索引，WHERE name = 'Alice' 要掃描整張表；有了 name 的索引，MySQL 直接定位到 Alice 的資料。

代價是：索引本身要佔空間，而且每次 INSERT、UPDATE、DELETE 都要同時維護索引。所以不是「越多索引越好」。
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

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
⚠️ <b>MySQL 8.x 新功能：</b>支援 DESC INDEX（降冪索引），讓 ORDER BY col DESC 也能用到索引，不再需要 filesort。
</div>

<!--
B-Tree 索引是最常用的，大多數情況下你不需要指定索引類型，MySQL 預設就是 B-Tree。

B-Tree 的特性是：支援等值查詢（=）、範圍查詢（BETWEEN、>、<）、前綴 LIKE（'abc%'），以及 ORDER BY 排序。

UNIQUE 索引同時提供兩個功能：確保唯一性（約束）+ 加速查詢（索引）。設定 UNIQUE 後不需要再額外建立索引。

複合索引（多欄位索引）是效能最佳化的重要工具。例如 WHERE category = '手機' AND price > 1000 這樣的查詢，建立 (category, price) 的複合索引比分別建兩個單獨索引更有效率。

⚠️ 複合索引有「最左前綴規則」：索引 (a, b, c) 可以用在 WHERE a=1、WHERE a=1 AND b=2、WHERE a=1 AND b=2 AND c=3，但不能單獨用在 WHERE b=2 或 WHERE c=3（因為 a 沒有）。
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

-- MySQL 8.x：降冪索引
CREATE INDEX idx_price_desc ON products (price DESC);

-- 查看資料表的所有索引
SHOW INDEX FROM products;

-- 刪除索引
DROP INDEX idx_category ON products;
```

<!--
建立索引的語法很直觀。

建立複合索引時，欄位的順序很重要。(category, price) 和 (price, category) 是兩個不同的索引，適用於不同的查詢模式：
- (category, price)：適合 WHERE category = ? AND price > ? 這樣的查詢
- (price, category)：適合 WHERE price > ? 這樣的查詢，或 ORDER BY price

MySQL 8.x 的降冪索引（DESC INDEX）讓 ORDER BY price DESC 查詢也能使用索引，不再需要 filesort 操作，大幅提升排序查詢的效能。

SHOW INDEX FROM products 可以查看一張表的所有索引，包括名稱、欄位、是否唯一等資訊。這在分析查詢效能時很常用。
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
索引不是越多越好，要根據查詢模式決定。

加索引的判斷原則：
1. 這個欄位常常出現在 WHERE、JOIN ON、ORDER BY 裡嗎？→ 適合加
2. 這個欄位的選擇性（不同值的數量）夠高嗎？→ is_active 只有 0/1，加索引效益很低；email 每筆都不同，加索引效益很高
3. 這張表的 INSERT/UPDATE 頻率高嗎？→ 如果寫入很頻繁，大量索引會讓寫入變慢
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
實際工作中，我通常的做法是：
1. 主鍵（PRIMARY KEY）：自動建立
2. 外鍵欄位（FOREIGN KEY）：一定要建
3. 常用 WHERE 條件欄位：根據查詢日誌決定
4. 其他：用 EXPLAIN 找出問題再決定

⚠️ 「先觀察，再最佳化」比「猜測性地預先加索引」更好。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第二部分
# EXPLAIN 執行計畫

<!--
進入第二部分：EXPLAIN。

EXPLAIN 是 MySQL 最重要的診斷工具。當你的查詢跑得慢，EXPLAIN 能告訴你 MySQL 是怎麼執行這個查詢的——有沒有用到索引、掃描了幾筆資料、用了什麼策略。

學會讀 EXPLAIN，你就能從「感覺查詢很慢」，找出「究竟哪裡慢，為什麼慢，怎麼改」。
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

EXPLAIN 的輸出包含多個欄位，其中最重要的是：

| 欄位 | 說明 |
| --- | --- |
| `type` | 存取類型（ALL = 最慢，const = 最快）|
| `key` | 實際使用的索引（NULL = 沒用索引）|
| `rows` | 預估需要掃描的資料筆數 |
| `Extra` | 額外資訊（Using filesort / Using index 等）|

<!--
EXPLAIN 是查詢最佳化的入口。

只要在 SELECT 前面加一個 EXPLAIN 關鍵字，MySQL 就會輸出這個查詢的執行計畫——包括它打算怎麼掃描表、有沒有用索引、預計掃描幾筆資料等。

重要：EXPLAIN 不會真的執行查詢，所以你可以安全地對大表的查詢使用 EXPLAIN，不用擔心它會鎖表或佔用太多資源。

EXPLAIN 的輸出有很多欄位，但我們重點看四個：type（存取方式）、key（用了哪個索引）、rows（掃描了多少行）、Extra（特殊提示）。

這四個欄位能幫你快速判斷查詢的效能問題。
-->

---

# EXPLAIN type 欄位

`type` 是 EXPLAIN 裡最重要的欄位，顯示 MySQL 選擇的存取類型：

| type 值 | 說明 | 效能 |
| --- | --- | --- |
| `const` | 主鍵或唯一索引等值查詢，最多一筆結果 | ⭐⭐⭐⭐⭐ 最佳 |
| `eq_ref` | 唯一索引 JOIN，每個組合最多一筆 | ⭐⭐⭐⭐⭐ |
| `ref` | 非唯一索引等值查詢 | ⭐⭐⭐⭐ |
| `range` | 索引範圍掃描（BETWEEN、>、<、IN）| ⭐⭐⭐ |
| `index` | 全索引掃描（比 ALL 好，但仍掃全索引）| ⭐⭐ |
| `ALL` | 全表掃描，沒有用到索引 | ⭐ 最差 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
⚠️ <b>警示訊號：</b>如果 type = ALL 且 rows 很大（幾千、幾萬），這個查詢幾乎肯定需要加索引。
</div>

<!--
type 欄位告訴你「MySQL 怎麼找資料的」。

const 是最理想的：WHERE id = 5，主鍵查詢，MySQL 直接定位到那一筆，速度最快。

ALL 是最差的：MySQL 掃描了整張表的每一列。如果 rows = 1,000,000，那 MySQL 要檢查一百萬筆資料才能找出你要的。

實際工作中，看到 type = ALL 配合 rows 很大，就要考慮加索引。

range 通常是可以接受的：它代表 MySQL 用了索引，只掃描了一個範圍的資料，不需要看全部。

記住一個原則：type 越靠近 const，查詢越快；看到 ALL 就要想想怎麼加索引。
-->

---

# EXPLAIN Extra 欄位解讀

| Extra 值 | 說明 | 應對方式 |
| --- | --- | --- |
| `Using index` | 只讀索引，不需要讀表（覆蓋索引）| 很好！不需要改 |
| `Using where` | 在 WHERE 條件篩選 | 通常正常，看是否可加索引 |
| `Using filesort` | 排序時無法使用索引，需額外排序操作 | 考慮在 ORDER BY 欄位加索引 |
| `Using temporary` | 需要建立暫時表（多見於 GROUP BY 或 UNION）| 效能警告，考慮重寫查詢或加索引 |
| `Using index condition` | Index Condition Pushdown（ICP）最佳化 | MySQL 自動最佳化，通常是好事 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
⚠️ <b>效能警告：</b>同時出現 <code>Using filesort</code> 和 <code>Using temporary</code>，代表這個查詢效能很差，需要重點最佳化。
</div>

<!--
Extra 欄位提供了更多關於查詢執行策略的資訊。

Using index 是最好的——它代表 MySQL 只讀了索引，不需要再去讀原始資料表，這叫「覆蓋索引」（Covering Index）。速度非常快。

Using filesort 是常見的效能問題：MySQL 需要額外的排序步驟，無法直接用索引的排序。通常出現在 ORDER BY 的欄位沒有索引的情況。

Using temporary 是更嚴重的問題：MySQL 需要建立一個暫時表來完成操作（常見於複雜的 GROUP BY 或 DISTINCT 查詢）。這會消耗額外的記憶體，而且速度慢。

如果同時看到 Using filesort 和 Using temporary，代表這個查詢可能需要大幅改寫或加入適當的複合索引。
-->

---

# EXPLAIN 實戰範例

用 EXPLAIN 診斷一個慢查詢並修正：

```sql
-- 慢查詢：category 和 price 沒有索引
EXPLAIN SELECT name, price
FROM products
WHERE category = '手機' AND price > 10000
ORDER BY price DESC;
-- 結果：type=ALL, key=NULL, rows=50000, Extra=Using filesort

-- 建立複合索引
CREATE INDEX idx_cat_price ON products (category, price);

-- 再次 EXPLAIN
EXPLAIN SELECT name, price
FROM products
WHERE category = '手機' AND price > 10000
ORDER BY price DESC;
-- 結果：type=range, key=idx_cat_price, rows=120, Extra=Using index condition
```

<!--
這個例子展示了 EXPLAIN 診斷 → 加索引 → 再次 EXPLAIN 驗證的完整流程。

修正前：
type=ALL 代表全表掃描，rows=50000 代表掃了整張表，key=NULL 代表完全沒用索引，Extra=Using filesort 代表排序需要額外操作。這個查詢很慢。

修正後：
type=range 代表使用了索引的範圍掃描，rows=120 代表只掃了 120 筆，key=idx_cat_price 代表用到了我們建立的複合索引，Using filesort 消失了（因為索引的順序就是 price 的順序）。

同一個查詢，從掃 50,000 筆變成掃 120 筆，速度差了幾百倍。

這就是 EXPLAIN + 索引最佳化的威力。
-->

---

# 總結

本章學了 Index 索引和 EXPLAIN 執行計畫：

- **索引原理** — 就像書本目錄，讓查詢不需要掃描整張表
- **索引種類** — B-Tree（預設）、UNIQUE、FULLTEXT、複合索引
- **何時加索引** — WHERE / JOIN / ORDER BY 的欄位；避免低選擇性欄位
- **EXPLAIN** — 在 SELECT 前加 EXPLAIN，查看執行計畫而不執行查詢
- **type 欄位** — ALL（最差）→ range → ref → const（最好）
- **Extra 欄位** — Using filesort / Using temporary 是效能警告

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
🚀 <b>下一章：</b>我們將學習 VIEW 視圖，學會如何把複雜的 SQL 查詢包裝成可重複使用的虛擬資料表！
</div>

<!--
學完這章，大家有了查詢最佳化的基本工具：索引和 EXPLAIN。

最佳實踐的流程：
1. 先寫出正確的查詢
2. 用 EXPLAIN 查看執行計畫
3. 看 type 和 rows，如果有問題（ALL + rows 很大），考慮加索引
4. 加索引後再用 EXPLAIN 驗證效果

不要盲目地加索引，要根據 EXPLAIN 的診斷結果，有針對性地最佳化。

做兩道練習！
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
-- type: ALL, key: NULL, rows: 1000000
-- Extra: Using where; Using filesort
```

**任務：**
1. 說明這個查詢的效能問題
2. 提出你的索引最佳化方案
3. 說明加索引後 EXPLAIN 預期會有什麼改變

<!--
這題考驗大家能否讀懂 EXPLAIN 輸出，並提出改善方案。

看到 type=ALL 和 rows=1000000：代表全表掃描，掃了一百萬筆，非常慢。

問題出在：customer_id 和 status 沒有索引，ORDER BY order_date 也沒有索引。

思考：要建立什麼樣的索引？單個欄位索引還是複合索引？
-->

---
layout: default
---

# 練習 1：解題提示

**問題分析：**
- `type=ALL`：全表掃描 100 萬筆
- `key=NULL`：沒有用到任何索引
- `Using filesort`：ORDER BY 無法用索引，需要額外排序

**最佳化方案：**

```sql
-- 建立複合索引，欄位順序：等值條件在前，範圍/排序在後
CREATE INDEX idx_cust_status_date
  ON orders (customer_id, status, order_date DESC);
```

<!--
複合索引的欄位順序很關鍵：
1. customer_id（等值查詢 = 100）放最前面
2. status（等值查詢 = 'completed'）放第二
3. order_date DESC（排序）放最後

這樣的順序讓 MySQL 能夠：先快速定位 customer_id=100 的資料，再在這個子集裡篩選 status='completed'，最後利用索引的順序直接排序（不需要 filesort）。
-->

---
layout: default
---

# 練習 1：解題提示（續）

**加索引後的預期 EXPLAIN 結果：**

| 欄位 | 改善前 | 改善後（預期）|
| --- | --- | --- |
| `type` | ALL | ref 或 range |
| `key` | NULL | idx_cust_status_date |
| `rows` | 1,000,000 | 少量（數十到數百）|
| `Extra` | Using where; Using filesort | Using index condition |

<!--
加索引後，rows 從 100 萬降到幾十到幾百，而且 Using filesort 消失了。

⚠️ 複合索引的最左前綴規則：只有從最左邊開始連續使用的欄位才能用到索引。(customer_id, status, order_date) 索引可以用在：WHERE customer_id=? 或 WHERE customer_id=? AND status=? 或 WHERE customer_id=? AND status=? AND order_date>?，但不能只用 WHERE status=? 或 WHERE order_date>?。
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
這題考驗大家對「什麼時候索引有效」的理解。

提示：第 4 個查詢的 LIKE '%iPhone%' 前面有 %，無法使用 B-Tree 索引。想想有什麼其他方案？

第 3 個查詢，stock > 0 是範圍查詢，ORDER BY price 是排序——複合索引 (stock, price) 能解決嗎？
-->

---
layout: default
---

# 練習 2：解題提示

| 查詢 | 索引方案 | 說明 |
| --- | --- | --- |
| `WHERE customer_id = ?` | `INDEX (customer_id)` | 外鍵欄位，標準索引 |
| `WHERE order_date BETWEEN ? AND ?` | `INDEX (order_date)` | 範圍查詢，B-Tree 索引有效 |
| `WHERE stock > 0 ORDER BY price` | `INDEX (stock, price)` | 複合索引：先篩 stock，再排序 price |
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
解答重點：

LIKE '%iPhone%' 前面有 %，B-Tree 索引無效——因為索引是按字首排序的，前面有萬用字元就無法用索引定位起點。

兩種替代方案：
1. FULLTEXT 索引：MySQL 內建的全文搜尋，適合對長文字做關鍵字搜尋。語法改用 MATCH...AGAINST。
2. 改寫為前綴搜尋 LIKE 'iPhone%'：去掉前導 %，B-Tree 索引就能生效。但這只找「以 iPhone 開頭」的商品，和「包含 iPhone」不完全相同。

實際電商系統如果需要強大的全文搜尋，通常會引入 Elasticsearch 等專門的搜尋引擎，MySQL 的 FULLTEXT 是個輕量替代方案。
-->

---
layout: end
---

# Q & A

有任何問題嗎？

<!--
現在開放 Q&A 時間。

大家對索引或 EXPLAIN 有沒有什麼疑問？

最重要的兩個觀念：
1. 看到 EXPLAIN type=ALL 且 rows 很大，就要考慮加索引
2. 複合索引的欄位順序很重要，遵守最左前綴規則

下一章我們要學 VIEW，把複雜的查詢包裝成可重複使用的虛擬表！
-->
