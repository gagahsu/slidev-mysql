---
theme: penguin
class: text-center
highlighter: shiki
lineNumbers: true
drawings:
  persist: false
transition: slide-left
title: 資料庫正規化
routeAlias: ch02
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
    資料庫正規化
  </h1>
  <div style="height: 4px; width: 320px; background: linear-gradient(90deg, #5eada0, #a7d9d0); border-radius: 2px; margin-bottom: 1.5rem;"></div>
  <p style="color: #4a7c7c; font-size: 1.15rem; font-style: italic;">
    「消除冗餘，讓資料保持一致」
  </p>
  <Link to="home" style="color: #9dc4c4; font-size: 0.85rem; margin-top: 2rem; text-decoration: none; letter-spacing: 0.05em;">← 返回目錄</Link>
</div>

<!--
大家好，歡迎來到第二章——資料庫正規化！

上一章我們說到「把不同的事情存在不同的表」，這個概念就是正規化的精神。

今天我們要把這個精神「系統化」。正規化是一套有步驟的設計方法，讓我們能夠有條理地消除資料冗餘，讓資料庫的設計更嚴謹。

學完這章，大家就能看著一張設計不好的表，知道怎麼一步一步把它「正規化」。
-->

---
layout: default
---

# Outline

- **為什麼需要正規化？** — 資料冗餘造成的三種異常
- **第一正規化（1NF）** — 確保每個欄位只有一個值
- **第二正規化（2NF）** — 消除部分相依
- **第三正規化（3NF）** — 消除遞移相依
- **正規化的取捨** — 何時反正規化（Denormalization）？

<!--
這章有五個部分。

第一部分先說「為什麼」——了解問題才能理解解法的意義。

接著每一個正規化都會有「規則說明 → 違反案例 → 修正後的設計」，讓大家看到完整的過程。

最後聊聊正規化的取捨，這是實際工作中很重要的判斷。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第一部分
# 為什麼需要正規化？

<!--
在學正規化的規則之前，我們先說為什麼需要它。

這部分我會用一個具體的例子，讓大家感受到「設計不好的表」究竟會造成什麼麻煩。
-->

---

# 沒有正規化的三種異常

設計不好的資料表，會帶來以下三種麻煩：

| 異常類型 | 說明 | 範例 |
| --- | --- | --- |
| **插入異常** | 想新增資料，卻因為其他欄位而受限 | 新課程還沒有學生，無法插入課程記錄 |
| **更新異常** | 更新一筆資料，必須同時修改多個地方 | 老師改電話，要改所有相關的課程記錄 |
| **刪除異常** | 刪除一筆資料，卻意外刪掉其他重要資料 | 刪除最後一個學生的記錄，連課程也消失了 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>正規化的目標：</b>「透過合理的表結構設計，消除這三種異常，讓資料的維護變得安全且簡單。」
</div>

<!--
這三種異常是所有資料庫設計問題的根源。

插入異常的例子：假設你有一張「學生選課」的表，把學生資訊和課程資訊混在一起。當你想新增一門課，但還沒有學生選這門課時，你沒辦法插入這筆資料——因為表的設計要求學生 ID 不能是 NULL。

更新異常：老師改了辦公室電話，但這個電話被存在每一筆選課記錄裡，你要把所有相關記錄都改掉，很容易漏改。

刪除異常：最後一個修這門課的學生退選了，你刪除了這筆記錄，結果這門課的所有資訊也跟著消失了。

正規化就是要系統性地解決這些問題。
-->

---

# 正規化的定義與目標

「正規化（Normalization）是一套將資料表分解成更小、更合理結構的設計方法，目的是消除資料冗餘與更新異常。」

| 正規化層次 | 英文 | 解決的問題 |
| --- | --- | --- |
| 第一正規化 | 1NF (First Normal Form) | 消除多值欄位與重複群組 |
| 第二正規化 | 2NF (Second Normal Form) | 消除部分相依（Partial Dependency）|
| 第三正規化 | 3NF (Third Normal Form) | 消除遞移相依（Transitive Dependency）|

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>循序漸進：</b>正規化是有順序的，2NF 必須先滿足 1NF，3NF 必須先滿足 2NF。
</div>

<!--
正規化有很多層次，我們今天主要介紹最常用的 1NF、2NF、3NF。

還有 BCNF（Boyce-Codd Normal Form）和更高階的 4NF、5NF，但在實際工作中，能做到 3NF 就已經非常好了。

重要的是記住：這三個層次是循序漸進的。如果你的設計還不是 1NF，就不用談 2NF 了。

我們一步一步來看。
-->

---

# 未正規化的壞資料表

試想這樣一張「學生選課」表，所有資料塞在一起：

| student_id | student_name | courses | teacher | teacher_phone |
| --- | --- | --- | --- | --- |
| S001 | Alice | Math, Science | 陳老師 | 0912-111 |
| S002 | Bob | Math | 陳老師 | 0912-111 |
| S003 | Carol | Science, English | 李老師 | 0912-222 |

**這張表有哪些問題？**

- `courses` 欄位存了多個值（Math, Science）
- 陳老師的電話重複出現多次（更新異常）
- 無法單獨新增一門課（插入異常）

<!--
看這張表，大家有沒有感覺到哪裡不對？

courses 欄位裡存了 "Math, Science"——一個欄位裡有兩個值。這讓我們沒辦法用 SQL 輕鬆查詢「選了 Math 的學生」，必須用字串搜尋，效率很差。

而且陳老師的電話出現了兩次。如果陳老師換電話，需要更新兩筆資料，如果有一百個學生選了陳老師的課，就要更新一百筆。

這張表違反了我們今天要學的 1NF、2NF、3NF。我們接下來就一步步把它修正。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第二部分
# 第一正規化（1NF）

<!--
進入第一個正規化：1NF。

1NF 的規則最直觀，我保證大家一下子就懂。
-->

---

# 1NF 的規則

第一正規化要求資料表達到以下條件：

| 規則 | 說明 |
| --- | --- |
| **原子性** | 每個欄位只能存一個值，不能存多個值（例如逗號分隔的列表）|
| **唯一識別** | 每一筆資料都能被唯一識別（通常是有 PRIMARY KEY）|
| **無重複群組** | 不應出現 course1、course2、course3 這樣的欄位組合 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>一句話記憶：</b>「每個格子只能填一個答案。」就像填表格，每個欄位只有一個空格讓你填。
</div>

<!--
1NF 的核心是「原子性」——每個格子只存一個值。

想像你在填一張紙本表格。表格上「姓名」那欄，你只會填一個名字，不會把兩個名字都寫在同一格。資料庫的欄位設計也是一樣的道理。

一旦一個欄位裡存了多個值（例如用逗號分隔），你的 SQL 查詢就會變得非常複雜，而且效能很差。

⚠️ 另一個常見的 1NF 違反：用 course1、course2、course3 三個欄位來存課程。這也違反 1NF，因為它假設了「最多只有三門課」，而且查詢起來很麻煩。
-->

---

# 違反 1NF 的案例

原本的表格，`courses` 欄位包含多個值：

| student_id | student_name | courses |
| --- | --- | --- |
| S001 | Alice | Math, Science |
| S002 | Bob | Math |
| S003 | Carol | Science, English |

**問題：**
- 無法用 `WHERE courses = 'Math'` 查詢，必須用 `LIKE '%Math%'`（效率差）
- 新增或移除某一門課非常麻煩，必須用字串操作

<!--
大家看這張表，courses 欄位裡存了像 "Math, Science" 這樣的字串。

如果我想查「選了 Math 的學生」，我沒辦法用 WHERE courses = 'Math'，因為 Alice 的記錄是 "Math, Science"，不等於 "Math"。

我只能用 WHERE courses LIKE '%Math%'，但這樣效率非常差，特別是資料量大的時候。

而且如果 Alice 要退選 Science，我需要用程式把字串裡的 "Science" 移除，這是非常笨拙的操作。
-->

---

# 修正為 1NF

解決方法：把每個「學生 + 課程」的組合拆成一筆資料：

| student_id | student_name | course |
| --- | --- | --- |
| S001 | Alice | Math |
| S001 | Alice | Science |
| S002 | Bob | Math |
| S003 | Carol | Science |
| S003 | Carol | English |

每一筆資料的 `course` 欄位只有一個值，符合原子性。複合主鍵為 `(student_id, course)`。

<!--
修正後，我們把每個「學生選了一門課」拆成一筆資料。

這樣，查詢「選了 Math 的學生」就變得很簡單：WHERE course = 'Math'。

注意：這張表的主鍵是複合主鍵 (student_id, course)，因為同一個學生可以選多門課，所以單獨的 student_id 無法唯一識別每一筆資料；同樣，單獨的 course 也不行。兩個合在一起才能唯一識別。

但你會發現，修正後的表有新的問題：student_name 依然重複出現。Alice 出現了兩次。這就是 2NF 要解決的問題。
-->

---

# 修正為 1NF — SQL

```sql
-- 1NF 後的資料表結構
CREATE TABLE student_courses (
  student_id   VARCHAR(10) NOT NULL,
  student_name VARCHAR(100) NOT NULL,
  course       VARCHAR(100) NOT NULL,
  PRIMARY KEY (student_id, course)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 插入範例資料
INSERT INTO student_courses VALUES
  ('S001', 'Alice', 'Math'),
  ('S001', 'Alice', 'Science'),
  ('S002', 'Bob', 'Math'),
  ('S003', 'Carol', 'Science'),
  ('S003', 'Carol', 'English');
```

<!--
這是 1NF 後的 SQL 設計。

每一筆資料的 course 欄位只有一個值，符合 1NF 的要求。

但大家仔細看：student_name 還是重複出現。Alice 的名字在兩筆資料裡都有。這代表如果 Alice 改名了，我要更新兩筆資料——這是更新異常。

這就是接下來 2NF 要解決的問題：消除部分相依（student_name 只相依於 student_id，不需要同時相依於 course）。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第三部分
# 第二正規化（2NF）

<!--
進入 2NF。

2NF 的概念比 1NF 稍微複雜一點，但用一個例子來說就很清楚了。

重點是：我們要消除「部分相依」。
-->

---

# 2NF 的規則 — 消除部分相依

第二正規化在滿足 1NF 的基礎上，要求：

| 規則 | 說明 |
| --- | --- |
| **滿足 1NF** | 先確保已達到 1NF |
| **無部分相依** | 所有非主鍵欄位，必須完整相依於整個複合主鍵，而不只是主鍵的一部分 |

**什麼是部分相依？**

- 複合主鍵：`(student_id, course)`
- `student_name` 只相依於 `student_id`（主鍵的一部分）→ **違反 2NF**
- `grade` 相依於 `(student_id, course)` 整體 → **符合 2NF**

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>2NF 只在有複合主鍵時才有意義。</b>單一欄位主鍵的表，天然就符合 2NF。
</div>

<!--
「部分相依」這個詞聽起來很學術，讓我用白話說明。

我們的複合主鍵是 (student_id, course)。現在問：student_name 這個欄位，是由 student_id 決定的，還是由 (student_id, course) 一起決定的？

答案是：student_name 只由 student_id 決定就夠了。不管 Alice 選了 Math 還是 Science，她的名字都是 Alice——course 對於決定 student_name 沒有任何貢獻。

這種「只相依於複合主鍵的一部分」就叫部分相依，是 2NF 要消除的。

反之，成績（grade）是由「哪個學生」加上「哪門課」一起決定的，這就是完整相依，符合 2NF。
-->

---

# 違反 2NF 的案例

1NF 後的表，`student_name` 對主鍵只有部分相依：

| **student_id** | **course** | student_name | grade |
| --- | --- | --- | --- |
| S001 | Math | Alice | 90 |
| S001 | Science | Alice | 85 |
| S002 | Math | Bob | 78 |

- `grade` 完整相依於 `(student_id, course)` ✅
- `student_name` 只相依於 `student_id`（部分相依）❌

<!--
看這張表，粗體的欄位是複合主鍵。

grade（成績）需要知道「哪個學生」+「哪門課」才能確定，所以它完整相依於整個複合主鍵，符合 2NF。

但 student_name 只需要知道「哪個學生」就能確定，和 course 無關。這就是部分相依，違反 2NF。

後果：Alice 的名字在每一筆選課記錄裡都重複，改名字要改很多筆。
-->

---

# 修正為 2NF — 拆分表格

解決方法：把部分相依的欄位拆出去，建立獨立的表：

**students 表（學生資料）：**

| student_id | student_name |
| --- | --- |
| S001 | Alice |
| S002 | Bob |
| S003 | Carol |

**student_courses 表（選課記錄）：**

| student_id | course | grade |
| --- | --- | --- |
| S001 | Math | 90 |
| S001 | Science | 85 |
| S002 | Math | 78 |

<!--
修正後，我們把 student_name 從 student_courses 表移出，建立獨立的 students 表。

現在 students 表只存學生的基本資料，student_courses 表只存選課記錄和成績。

好處很明顯：Alice 改名字，只需要改 students 表的一筆資料，不需要動 student_courses 表。

這就是消除部分相依的效果。
-->

---

# 修正為 2NF — SQL

```sql
CREATE TABLE students (
  student_id   VARCHAR(10)  NOT NULL,
  student_name VARCHAR(100) NOT NULL,
  PRIMARY KEY (student_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE student_courses (
  student_id VARCHAR(10)  NOT NULL,
  course     VARCHAR(100) NOT NULL,
  grade      TINYINT,
  PRIMARY KEY (student_id, course),
  FOREIGN KEY (student_id) REFERENCES students(student_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

<!--
這是 2NF 後的 SQL 設計。

students 表主鍵是 student_id（單一主鍵），student_courses 表主鍵是 (student_id, course)（複合主鍵）。

FOREIGN KEY (student_id) REFERENCES students(student_id) 確保 student_courses 表裡的每個 student_id 都對應到 students 表裡真實存在的學生。

但這張表還有一個問題沒解決：如果我們再加入 teacher 和 teacher_phone 欄位，teacher_phone 只相依於 teacher，這是「遞移相依」——3NF 要解決的問題。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第四部分
# 第三正規化（3NF）

<!--
進入最後一個主要的正規化層次：3NF。

3NF 要解決的是「遞移相依」，聽起來複雜，但用例子說很清楚。
-->

---

# 3NF 的規則 — 消除遞移相依

第三正規化在滿足 2NF 的基礎上，要求：

| 規則 | 說明 |
| --- | --- |
| **滿足 2NF** | 先確保已達到 2NF |
| **無遞移相依** | 非主鍵欄位不能相依於另一個非主鍵欄位 |

**什麼是遞移相依？**

- `employee_id` → `state_code` → `home_state`
- `home_state` 相依於 `state_code`，不是直接相依於主鍵 `employee_id`
- 這就是「遞移相依」：A → B → C，C 透過 B 才相依於 A

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>口訣：</b>非主鍵欄位只能相依於主鍵，不能相依於其他非主鍵欄位。
</div>

<!--
遞移相依的意思是：A 決定 B，B 決定 C，所以 A 間接決定 C。

我們用具體的例子說明：員工表裡有 employee_id、state_code（州代碼）、home_state（州名稱）。

employee_id 決定了 state_code（每個員工有一個州代碼）。
state_code 決定了 home_state（州代碼 26 = Michigan，56 = Wyoming）。

所以 home_state 是透過 state_code 間接相依於 employee_id，這就是遞移相依。

問題：如果州代碼 26 對應的州名稱改了（比如政治原因改名），我需要更新所有州代碼為 26 的員工記錄，而不只是更改一個地方。
-->

---

# 違反 3NF 的案例

員工表裡，`home_state` 透過 `state_code` 間接相依於主鍵：

| employee_id | name | state_code | home_state |
| --- | --- | --- | --- |
| E001 | Alice | 26 | Michigan |
| E002 | Bob | 56 | Wyoming |
| E003 | Carol | 26 | Michigan |

- `state_code` 相依於 `employee_id` ✅（直接）
- `home_state` 相依於 `state_code`（遞移相依）❌

**問題：** Michigan 若改名，要更新 E001 和 E003 兩筆資料。

<!--
看這張表，employee_id 是主鍵。

state_code 直接相依於 employee_id，這沒問題。

但 home_state 相依於 state_code，不是直接相依於 employee_id。州代碼 26 代表 Michigan，這個對應關係和「是哪個員工」無關——只要是 state_code = 26，home_state 就一定是 Michigan。

所以 home_state 是透過 state_code「間接」相依於 employee_id，這就違反了 3NF。

後果：如果同一個州有很多員工，州名稱就會重複出現很多次；如果州名稱改了，要更新很多筆資料。
-->

---

# 修正為 3NF — 拆出 states 表

解決方法：把遞移相依的欄位拆出去，建立獨立的表：

**states 表（州資料）：**

| state_code | home_state |
| --- | --- |
| 26 | Michigan |
| 56 | Wyoming |

**employees 表（修正後）：**

| employee_id | name | state_code |
| --- | --- | --- |
| E001 | Alice | 26 |
| E002 | Bob | 56 |
| E003 | Carol | 26 |

<!--
修正後，我們把 state_code → home_state 這個對應關係移到獨立的 states 表裡。

employees 表只保留 state_code（外鍵），不再存 home_state。

好處：Michigan 改名的話，只需要改 states 表的一筆資料，所有員工的記錄自動就正確了——因為他們都是透過 state_code 參照 states 表。

這就是消除遞移相依的效果：讓每個非主鍵欄位只直接相依於主鍵。
-->

---

# 修正為 3NF — SQL

```sql
CREATE TABLE states (
  state_code CHAR(2)     NOT NULL,
  home_state VARCHAR(50) NOT NULL,
  PRIMARY KEY (state_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE employees (
  employee_id VARCHAR(10)  NOT NULL,
  name        VARCHAR(100) NOT NULL,
  state_code  CHAR(2)      NOT NULL,
  PRIMARY KEY (employee_id),
  FOREIGN KEY (state_code) REFERENCES states(state_code)
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

<!--
這是 3NF 後的 SQL 設計。

states 表存的是「州代碼和州名稱的對應關係」，employees 表只存 state_code 外鍵。

ON UPDATE CASCADE 表示：如果 states 表的 state_code 被更新，employees 表裡所有對應的 state_code 也會自動更新，不會造成資料不一致。

現在，每個非主鍵欄位都直接相依於主鍵，沒有任何遞移相依，這張設計達到了 3NF！
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第五部分
# 正規化的取捨

<!--
學完三個正規化層次，我想跟大家聊一個實際工作中很重要的問題：

「正規化是不是越高越好？」

答案是：不一定。我們來說說什麼情況下要考慮反正規化。
-->

---

# 正規化 vs 反正規化（Denormalization）

| 面向 | 正規化 | 反正規化 |
| --- | --- | --- |
| **資料冗餘** | 幾乎沒有 | 刻意保留部分冗餘 |
| **更新效率** | 高（只需改一個地方）| 低（需要同步更新多處）|
| **查詢效率** | 可能需要多次 JOIN | 直接讀取，查詢快 |
| **適用場景** | OLTP（頻繁寫入、更新）| OLAP（大量讀取、分析）|

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>實務建議：</b>一般應用系統預設遵循 3NF，當遇到明確的效能問題時，再考慮局部的反正規化。不要過早優化。
</div>

<!--
正規化讓資料結構更嚴謹，但有時候會帶來查詢時需要多次 JOIN 的成本。

反正規化是反其道而行：刻意保留一些冗餘，換取查詢速度的提升。

最常見的反正規化場景是資料倉儲（Data Warehouse）或報表系統。這類系統讀取次數遠多於寫入，而且資料通常是批次更新，不需要即時一致性。

但對於一般的 Web 應用系統（電商、社群媒體），預設應該遵循 3NF，確保資料的完整性和一致性。遇到效能瓶頸時，再考慮加入冗餘欄位。
-->

---

# 何時考慮反正規化？

反正規化是一種有意識的取捨，不是設計失誤：

| 情境 | 做法 | 範例 |
| --- | --- | --- |
| 頻繁查詢的彙總數值 | 在表中加入冗餘的計算欄位 | `orders.item_count`（不用每次 COUNT）|
| 報表系統的多表 JOIN | 建立反正規化的寬表 | 直接把所有需要的欄位存在一張表 |
| 歷史快照（不需即時更新）| 儲存當下的資料副本 | `order_history.customer_name`（訂單成立時的名字）|

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
⚠️ <b>注意：</b>反正規化會增加維護的複雜度，必須自行確保冗餘資料的一致性，MySQL 不會幫你管。
</div>

<!--
反正規化最典型的例子是「訂單快照」。

一般電商系統，訂單建立後，客戶的姓名和地址可能之後會修改。但訂單記錄需要保存「下單當時」的客戶資訊，而不是「現在」的客戶資訊。所以在 orders 表裡存一份 customer_name 和 shipping_address 的副本，是合理的反正規化。

但代價是：你需要確保這些欄位在訂單建立時正確寫入，之後就不再更新。這個維護責任由你的應用程式負責，而不是資料庫。

⚠️ 反正規化必須是有意識的決定，並且要有充分的理由和文件說明，不是因為設計不好才這樣。
-->

---

# 總結

本章我們學了資料庫正規化的三個層次：

- **為什麼正規化** — 消除插入異常、更新異常、刪除異常三種問題
- **1NF** — 每個欄位只存一個值（原子性），有 PRIMARY KEY
- **2NF** — 消除部分相依：非主鍵欄位必須完整相依於複合主鍵
- **3NF** — 消除遞移相依：非主鍵欄位不能相依於另一個非主鍵欄位
- **取捨** — 一般系統遵循 3NF；有明確效能需求時才考慮反正規化

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
🚀 <b>下一章：</b>我們將學習資料表關聯設計，用 FOREIGN KEY 實作一對一、一對多、多對多三種關聯！
</div>

<!--
學完這章，大家應該能夠看著一張設計不好的表，說出「這裡違反了 2NF，因為有部分相依」，然後知道怎麼修正它。

1NF 確保每個格子只有一個值，2NF 消除「只靠主鍵一部分就能決定的欄位」，3NF 消除「非主鍵欄位相依於另一個非主鍵欄位」。

這三個層次是循序漸進的，請一定要按順序理解。

做兩題練習，把今天的概念鞏固一下！
-->

---
layout: default
---

# 練習 1：任務說明
### 找出正規化問題

以下是一張「訂單」表，找出它違反了哪些正規化規則：

| order_id | product_id | product_name | product_price | customer_id | customer_name | customer_city |
| --- | --- | --- | --- | --- | --- | --- |

複合主鍵為 `(order_id, product_id)`。

**任務：**
1. 這張表是幾 NF？為什麼？
2. 找出所有的部分相依和遞移相依
3. 說明應該如何拆分這張表

<!--
這題要大家分析一張真實情境的表。

提示一：複合主鍵是 (order_id, product_id)。

提示二：思考每個非主鍵欄位是相依於整個複合主鍵，還是只相依於其中一個？

提示三：customer_city 相依於什麼？是直接相依於主鍵，還是透過某個欄位間接相依？
-->

---
layout: default
---

# 練習 1：解題提示

**分析結果：**

| 欄位 | 相依關係 | 問題 |
| --- | --- | --- |
| `product_name` | 只相依於 `product_id` | 部分相依，違反 2NF |
| `product_price` | 只相依於 `product_id` | 部分相依，違反 2NF |
| `customer_name` | 只相依於 `customer_id` | 部分相依，違反 2NF |
| `customer_city` | 只相依於 `customer_id` | 部分相依，違反 2NF |

**應拆分為：** `products(product_id, name, price)`、`customers(customer_id, name, city)`、`order_items(order_id, product_id, quantity)` 三張表。

<!--
這張表的主鍵是 (order_id, product_id)，而所有的非主鍵欄位都只相依於其中一個主鍵欄位：

product_name 和 product_price 只需要 product_id 就能決定，不需要知道 order_id。
customer_name 和 customer_city 只需要 customer_id 就能決定。

所以這四個欄位都違反了 2NF（部分相依）。

修正方式：把商品資訊獨立成 products 表，把客戶資訊獨立成 customers 表，訂單表只保留需要完整主鍵才能決定的欄位（例如數量、下單時間）。
-->

---
layout: default
---

# 練習 2：任務說明
### 設計一個正規化的學生資料庫

設計一個達到 3NF 的學生資料庫，需要記錄：

- 學生資料（姓名、學號、系所代碼）
- 系所資料（系所代碼、系所名稱、所在學院）
- 課程資料（課程編號、課程名稱、學分數）
- 選課記錄（哪個學生選了哪門課、成績）

**任務：**
1. 設計所有必要的資料表並說明主鍵與外鍵
2. 確認設計達到 3NF（無部分相依、無遞移相依）
3. 用 SQL CREATE TABLE 寫出來

<!--
這題讓大家從頭設計一個符合 3NF 的資料庫。

思考方向：
1. 「系所代碼 → 系所名稱 → 所在學院」，這是遞移相依嗎？
2. 選課記錄的主鍵應該是什麼？
3. 哪些表需要 FOREIGN KEY？
-->

---
layout: default
---

# 練習 2：解題提示（1／2）

```sql
CREATE TABLE departments (
  dept_code VARCHAR(10)  NOT NULL,
  dept_name VARCHAR(100) NOT NULL,
  college   VARCHAR(100) NOT NULL,
  PRIMARY KEY (dept_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE students (
  student_id VARCHAR(10)  NOT NULL,
  name       VARCHAR(100) NOT NULL,
  dept_code  VARCHAR(10)  NOT NULL,
  PRIMARY KEY (student_id),
  FOREIGN KEY (dept_code) REFERENCES departments(dept_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

<!--
這是前兩張表的設計。

departments 表把「系所代碼、系所名稱、所在學院」存在一起。注意這裡沒有遞移相依：college 直接相依於主鍵 dept_code，不是透過其他非主鍵欄位。

students 表只存學生基本資料，用 dept_code 外鍵參照 departments。建立順序很重要：departments 必須先建立，students 才能參照它。
-->

---
layout: default
---

# 練習 2：解題提示（2／2）

```sql
CREATE TABLE courses (
  course_id VARCHAR(10)  NOT NULL,
  name      VARCHAR(100) NOT NULL,
  credits   TINYINT      NOT NULL,
  PRIMARY KEY (course_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE enrollments (
  student_id VARCHAR(10) NOT NULL,
  course_id  VARCHAR(10) NOT NULL,
  grade      DECIMAL(4,1),
  PRIMARY KEY (student_id, course_id),
  FOREIGN KEY (student_id) REFERENCES students(student_id),
  FOREIGN KEY (course_id)  REFERENCES courses(course_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

<!--
這是後兩張表的設計。

enrollments 是多對多的中介表：一個學生可以選多門課，一門課可以被多個學生選。主鍵是複合主鍵 (student_id, course_id)，grade 完整相依於整個複合主鍵，符合 2NF。

兩個 FOREIGN KEY 分別參照 students 和 courses，確保選課記錄的學生和課程都真實存在。

這個設計達到了 3NF！
-->

---
layout: end
---

# Q & A

有任何問題嗎？

<!--
現在開放 Q&A 時間。

大家對正規化有沒有什麼疑問？1NF、2NF、3NF 的概念還清楚嗎？

特別是 2NF 和 3NF 的差別，如果還不太清楚，歡迎現在提問。

下一章我們會更實際地看各種關聯類型，以及如何用 FOREIGN KEY 實作它們。
-->
