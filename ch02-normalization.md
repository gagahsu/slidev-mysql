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
大家好，歡迎來到第二章：資料庫正規化。

上一章我們提到「把不同的事情存在不同的表」，這其實就是正規化的精神。只是光靠感覺拆表，很容易拆得不一致。

這一章要把這個精神變成一套有步驟的方法。學完之後，大家看到一張設計不好的表，就能一步一步判斷它哪裡有問題，再把它拆成乾淨的結構。
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
這一章的路線是這樣的。先看沒有正規化會遇到哪三種異常，理解問題在哪。接著依序學 1NF、2NF、3NF，每一個都會走過規則、違反案例、修正後設計這三步。最後聊聊實務上的取捨，什麼時候反而要刻意保留冗餘。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第一部分
# 為什麼需要正規化？

<!--
在學規則之前，我們先看看設計不好的表，到底會帶來哪些麻煩。
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
表格裡列了三種異常，我們用一張「學生選課」表來想像，學生和課程的資料全部混在一起。

第一種是插入異常。開了一門新課，還沒有學生選，可是表裡一定要有學生，這門課就沒辦法先存進去。

第二種是更新異常。老師換了辦公室電話，可是電話存在每一筆選課記錄裡，要一筆一筆改，很容易漏。

第三種是刪除異常。最後一個學生退選，我們刪掉這筆記錄，結果整門課的資訊也跟著消失了。

正規化的目標，就是透過合理的表結構，把這三種異常消除掉。
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
那正規化到底是什麼呢？「正規化是一套將資料表分解成更小、更合理結構的設計方法，目的是消除資料冗餘與更新異常。」

正規化有好幾個層次，表格裡列的是最常用的三個。1NF 處理一格塞多個值的問題，2NF 處理部分相依，3NF 處理遞移相依。後面還有 BCNF、4NF 這些更高的層次，不過在實際工作中，能做到 3NF 就已經很好了。

要記住的是，這三層是循序漸進的，就像爬樓梯。要先滿足 1NF 才談得上 2NF，滿足 2NF 才談得上 3NF。
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
我們先來看一張還沒正規化的學生選課表，大家想想看，哪裡不對勁？

第一個問題在 `courses` 欄位。Alice 那一格寫著 Math 和 Science，一個格子塞了兩個值。這樣想找出選了 Math 的學生，就只能用字串去比對，又慢又不準。

第二個問題是陳老師的電話出現了好幾次。如果有一百個學生選陳老師的課，電話就重複一百次，陳老師換電話時就要改一百筆。

第三個問題是，沒有學生的課根本存不進來。

這張表把 1NF、2NF、3NF 都違反了。接下來我們就一層一層，把它修好。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第二部分
# 第一正規化（1NF）

<!--
第一層是 1NF。它的規則最直觀，從這裡開始最適合。
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
1NF 的核心是「原子性」，用一句話記就是「每個格子只能填一個答案」。

想像我們在填一張紙本表格，姓名那一欄只會寫一個名字，不會把兩個人的名字擠在同一格。資料表也是同樣的道理。

表格裡還有另外兩條規則。每一筆資料要能被唯一識別，通常就是要有 PRIMARY KEY。另外不能有重複群組，例如用 `course1`、`course2`、`course3` 三個欄位存課程。這種寫法很常見，但它等於假設每個人最多只選三門課，查詢起來也很麻煩，同樣違反 1NF。
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
我們回到剛才那張表，只看學生和課程這三欄。

`courses` 欄位存的是像「Math 逗號 Science」這樣的字串。如果想查選了 Math 的學生，用 `WHERE courses = 'Math'` 是查不到 Alice 的，因為她那格的內容不只是 Math。

最後只能改用 `LIKE '%Math%'` 做模糊比對。資料一多，這種查詢會非常慢。

更麻煩的是修改。Alice 想退選 Science，我們得把那串字串拆開、拿掉 Science、再組回去。原本一個簡單的退選，變成了很笨拙的字串操作。
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
修正的方法很直接，把每一個「學生選了一門課」拆成一筆資料。

現在每一格的 `course` 都只有一個值，符合原子性了。要查選了 Math 的學生，用 `WHERE course = 'Math'` 就能查到。

這張表的主鍵是 `student_id` 加 `course` 的複合主鍵。因為同一個學生會選很多門課，單看學號不夠，單看課程也不夠，兩個合起來才能唯一識別一筆資料。

不過大家應該也發現了，Alice 的名字出現了兩次。這個新問題，就是下一層 2NF 要處理的。
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
這是 1NF 版本的 SQL，目的是把剛才的表格真正建出來。

關鍵在 `PRIMARY KEY (student_id, course)` 這一行，它把兩個欄位合在一起當主鍵。下面的 `INSERT` 一次放進五筆資料，每一筆都只有一門課。

執行後，查詢 `student_courses` 會看到五筆資料，跟上一頁的表格一模一樣。

但請大家留意 `student_name`。Alice 和 Carol 的名字都各出現了兩次。如果 Alice 改名，就要改兩筆資料，這又是更新異常。

問題的原因是，`student_name` 只需要學號就能決定，跟課程一點關係都沒有。這就叫「部分相依」，也是我們下一步要消除的。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第三部分
# 第二正規化（2NF）

<!--
1NF 解決了一格多值，可是名字還在重複。接下來看 2NF 怎麼消除部分相依。
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
「部分相依」聽起來很學術，我們用白話來看。

主鍵是學號加課程。現在問一個問題：學生的名字，是由學號決定的，還是要學號和課程一起決定？答案是只要學號就夠了。不管 Alice 選 Math 還是 Science，她都叫 Alice，課程對名字沒有任何影響。

這種「只相依於複合主鍵的一部分」，就叫做部分相依，違反 2NF。

反過來看成績 `grade`，一定要知道是哪個學生、加上哪門課，才能確定分數，這就是完整相依，符合 2NF。

所以 2NF 只在有複合主鍵時才有意義，主鍵只有一個欄位的表，天生就符合 2NF。
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
我們把剛才的概念放進表格裡看。粗體的 `student_id` 和 `course` 是複合主鍵。

先看 `grade`。要知道哪個學生、加上哪門課，才能確定成績，所以它完整相依於整個主鍵，沒有問題。

再看 `student_name`。只要知道學號就能確定名字，跟課程無關，這就是部分相依，違反 2NF。

後果就是 Alice 的名字會跟著她的每一筆選課記錄重複出現。她選了十門課，名字就存十次，改名的時候也要改十次。
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
修正的方法，是把部分相依的欄位拆出去，自己成立一張表。

我們建一張 `students` 表，只放學號和姓名，每個學生只出現一次。原本的選課表只留下學號、課程和成績。

這樣 Alice 要改名，只要改 `students` 表裡的一筆資料，選課記錄完全不用動。

這就是 2NF 的效果，每張表裡的欄位，都完整相依於自己的主鍵。
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
這是 2NF 版本的 SQL，把剛才拆好的兩張表建出來。

`students` 用單一欄位 `student_id` 當主鍵。`student_courses` 還是用學號加課程的複合主鍵，但已經沒有 `student_name` 了。

關鍵是 `FOREIGN KEY (student_id) REFERENCES students(student_id)` 這一行。它確保選課記錄裡的每個學號，都能在 `students` 表裡找到真正存在的學生。

執行後，我們會得到兩張透過學號連起來的表。

不過如果之後要再加上授課老師和老師電話，又會遇到另一種問題。老師電話是由老師決定的，而不是由主鍵直接決定，這就是 3NF 要處理的「遞移相依」。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第四部分
# 第三正規化（3NF）

<!--
最後一層是 3NF，要消除的是遞移相依。名字聽起來複雜，用例子看就清楚了。
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
遞移相依的意思是，A 決定 B，B 又決定 C，所以 A 是間接決定了 C。

我們用員工表當例子。員工編號決定了他住在哪個州的州代碼，州代碼又決定了州名稱，例如代碼 26 就是 Michigan。所以州名稱是透過州代碼，間接相依於員工編號。

這就像傳話遊戲，消息不是直接從源頭來的，而是透過中間人轉述。

3NF 的口訣是「非主鍵欄位只能相依於主鍵，不能相依於其他非主鍵欄位」。如果 Michigan 改了名字，在違反 3NF 的設計裡，我們就得更新所有住在那裡的員工資料。
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
我們把員工表攤開來看，主鍵是 `employee_id`。

`state_code` 直接由員工編號決定，這沒問題。

但 `home_state` 不一樣。只要州代碼是 26，州名稱就一定是 Michigan，跟是哪個員工完全無關。它是透過 `state_code` 才連到主鍵的，這就違反了 3NF。

後果大家可以從表格裡看到。Alice 和 Carol 都住在 Michigan，州名稱就重複存了兩次。如果 Michigan 改名，就要同時改 E001 和 E003 兩筆。員工越多，要改的地方就越多。
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
修正方法跟 2NF 很像，把遞移相依的部分拆出去，獨立成一張表。

我們建一張 `states` 表，專門存州代碼和州名稱的對應。`employees` 表只保留 `state_code`，不再存州名稱。

這樣 Michigan 如果改名，只要改 `states` 表裡的一筆資料。所有員工都是透過州代碼去查州名稱，所以會自動拿到新名字。

現在每個非主鍵欄位都直接相依於自己表裡的主鍵，這就是 3NF。
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
這是 3NF 版本的 SQL，把州資料和員工資料分開建立。

`states` 要先建，因為 `employees` 要參照它。`employees` 裡用 `FOREIGN KEY (state_code) REFERENCES states(state_code)` 連到州資料。

下面多了一行 `ON UPDATE CASCADE`。它的意思是，如果 `states` 表裡的州代碼被修改，員工表裡對應的代碼也會自動跟著改，資料不會對不上。

執行後，每張表裡的非主鍵欄位都只相依於自己的主鍵，沒有部分相依，也沒有遞移相依，這個設計就達到 3NF 了。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第五部分
# 正規化的取捨

<!--
學完三層正規化，我們來想一個實務問題：正規化是不是越徹底越好？答案是不一定。
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
表格把正規化和反正規化放在一起比較。

正規化讓資料幾乎沒有冗餘，更新時只要改一個地方。代價是表拆得越細，查詢時就要 JOIN 越多張表。

反正規化則反過來，刻意保留一些冗餘，讓查詢可以直接讀，速度比較快。代價是更新時要同步改好幾個地方。

所以它們適合的場景不同。一般的網站和應用系統，寫入和更新很頻繁，預設遵循 3NF。報表或資料分析系統，大部分時間都在讀，才比較適合反正規化。

實務上的建議是，先照 3NF 設計，真的遇到明確的效能問題，再局部調整，不要過早優化。
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
反正規化是一種有意識的取捨，不是設計失誤。表格列了三種常見情境，我們挑最典型的「歷史快照」來說。

在電商系統裡，客人下單之後，可能會改名字或改地址。可是訂單需要保留的，是下單那一刻的資訊，而不是現在的資訊。所以在訂單裡另外存一份當時的客戶姓名，是合理的反正規化。

另外像在 `orders` 裡存一個 `item_count`，就不用每次都重新計算商品數量。

不過要特別提醒，這些冗餘資料的一致性要由我們自己的程式負責，MySQL 不會幫忙管。所以反正規化一定要有明確的理由，最好也寫成文件，讓團隊知道為什麼這樣設計。
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
我們來整理這一章。正規化是為了消除插入、更新、刪除三種異常。1NF 讓每個格子只放一個值，2NF 消除只靠部分主鍵就能決定的欄位，3NF 消除透過其他欄位間接決定的欄位。這三層要按順序來。

實務上，一般系統以 3NF 為預設，有明確效能需求時才考慮反正規化。

接下來，我們用兩題練習把這些判斷練熟。
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
第一題是分析題。畫面上是一張訂單表，主鍵是 `order_id` 加 `product_id`。

請大家判斷三件事：這張表是第幾正規化？裡面有哪些部分相依和遞移相依？應該怎麼拆？

可以這樣思考：把每個非主鍵欄位拿出來問一次，它是需要整個主鍵才能決定，還是只要其中一個欄位就夠了？另外 `customer_city` 又是由誰決定的？

我們先暫停一下，自己分析看看。

【講師】給大家五分鐘，可以先請同學說說看這張表是幾 NF。
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
我們來看分析結果。這張表只到 1NF，因為商品和客戶的欄位，都不是由整個主鍵決定的。

`product_name` 和 `product_price` 只要知道 `product_id` 就能決定，跟是哪一張訂單無關，這是部分相依。客戶的姓名和城市則是跟著訂單走，由 `order_id` 經過 `customer_id` 再決定，也只用到主鍵的一部分，而且中間還多經過一層 `customer_id`，同時帶有遞移相依。

修正方式是拆成三張表。商品資料獨立成 `products`，客戶資料獨立成 `customers`。訂單明細 `order_items` 只留下真正需要整個主鍵才能決定的欄位，例如購買數量。
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
第二題，我們從頭設計一個達到 3NF 的學生資料庫，要記錄學生、系所、課程，以及選課成績。

請大家寫出所有資料表，說明主鍵和外鍵，最後用 `CREATE TABLE` 寫出來。

這裡有三個思考方向。學生資料裡如果直接放系所名稱和學院，會不會形成遞移相依？選課記錄的主鍵應該是什麼？哪些表需要外鍵？

我們先暫停一下，動手設計看看。

【講師】給大家十到十五分鐘，可以提醒先畫出表之間的關係再寫 SQL。
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
我們來看解答的前兩張表。

第一個思考方向的答案是，會。如果把系所名稱和學院直接放在學生資料裡，它們是透過系所代碼才決定的，就形成遞移相依。所以我們把系所獨立成 `departments` 表，用 `dept_code` 當主鍵，名稱和學院都直接相依於它。

`students` 表只存學號、姓名，和一個 `dept_code` 外鍵，指向 `departments`。

建立順序一樣要注意，`departments` 必須先建，`students` 才能參照它。執行後，每個學生都一定屬於一個真正存在的系所。
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
接著看後兩張表。`courses` 存課程編號、名稱和學分，很單純。

重點是 `enrollments` 這張選課表。一個學生可以選很多門課，一門課也會有很多學生，所以這是多對多的關係，需要一張中介表。

它的主鍵是學號加課程編號，這就回答了第二個思考方向。成績要同時知道學生和課程才能決定，完整相依於整個主鍵。兩個外鍵分別指向 `students` 和 `courses`，確保選課記錄裡的學生和課程都真實存在。

這四張表合起來，沒有部分相依，也沒有遞移相依，整個設計就達到 3NF 了。
-->

---
layout: end
---

# Q & A

有任何問題嗎？

<!--
今天我們從三種異常出發，依序學了 1NF、2NF、3NF，也知道正規化不是越徹底越好，反正規化是有意識的取捨。

2NF 和 3NF 一開始容易混淆。可以記住一個分辨方法：2NF 看的是欄位有沒有只靠主鍵的一部分，3NF 看的是欄位有沒有透過其他非主鍵欄位。

下一章，我們會實際設計一對一、一對多、多對多這三種關聯。我們下一章見。

【講師】開放提問，特別可以確認大家是否分得清 2NF 和 3NF 的差別。
-->
