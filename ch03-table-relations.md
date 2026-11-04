---
theme: penguin
class: text-center
highlighter: shiki
lineNumbers: true
drawings:
  persist: false
transition: slide-left
title: 資料表關聯設計
routeAlias: ch03
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
    資料表關聯設計
  </h1>
  <div style="height: 4px; width: 320px; background: linear-gradient(90deg, #5eada0, #a7d9d0); border-radius: 2px; margin-bottom: 1.5rem;"></div>
  <p style="color: #4a7c7c; font-size: 1.15rem; font-style: italic;">
    「讓資料之間產生有意義的連結」
  </p>
  <Link to="home" style="color: #9dc4c4; font-size: 0.85rem; margin-top: 2rem; text-decoration: none; letter-spacing: 0.05em;">← 返回目錄</Link>
</div>

<!--
大家好，歡迎來到第三章：資料表關聯設計。

前兩章我們學了設計原則和正規化，把不同的事情拆進不同的表。可是表拆開之後，新的問題就來了：要怎麼把它們再連起來？

這一章就是要回答這個問題。我們會認識三種關聯類型，並且學會用 FOREIGN KEY 在 MySQL 裡把它們實作出來。
-->

---
layout: default
---

# Outline

- **關聯的種類** — 一對一、一對多、多對多
- **用 FOREIGN KEY 實作關聯** — 語法、ON DELETE / ON UPDATE 選項
- **多對多的實作** — 中介表（Junction Table）
- **關聯設計注意事項** — 索引、建立順序、常見錯誤

<!--
這一章分成四段。先認識一對一、一對多、多對多三種關聯。接著學 FOREIGN KEY 的完整語法，特別是刪除和更新時的連動選項。然後花一整段把最容易搞錯的多對多講清楚。最後整理幾個實務上常踩的坑。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第一部分
# 關聯的種類

<!--
我們先來認識三種關聯，每一種都會先用生活例子建立直覺，再看技術定義。
-->

---

# 什麼是資料表關聯？

「資料表關聯，就是用共同的欄位把兩張表連起來，表達現實世界中事物之間的關係。」

| 關聯類型 | 說明 | 生活比喻 |
| --- | --- | --- |
| **一對一（1:1）** | A 的每筆資料對應 B 的恰好一筆 | 一個人只有一張身份證 |
| **一對多（1:N）** | A 的一筆資料對應 B 的多筆 | 一個媽媽可以有多個孩子 |
| **多對多（M:N）** | A 的多筆對應 B 的多筆 | 一個學生選多門課，一門課有多個學生 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>最常見的是一對多。</b>電商的顧客與訂單、部落格的作者與文章，都是一對多。
</div>

<!--
現實世界裡的事物，彼此之間都有關係。「資料表關聯，就是用共同的欄位把兩張表連起來，表達現實世界中事物之間的關係。」

表格裡的三種關聯，都可以用生活來理解。一個人只有一張身分證，這是一對一。一個媽媽可以有好幾個孩子，這是一對多。一個學生選很多門課，一門課也有很多學生，這是多對多。

這三種裡面，最常見的是一對多。像電商的顧客和訂單，部落格的作者和文章，都是一對多。只要把一對多學會，另外兩種就很好理解了。
-->

---

# 一對一（One-to-One）

「一對一關聯：A 表的每一筆資料，對應到 B 表的恰好一筆資料。」

**適用場景：**
- 把龐大的表拆分，把不常用的欄位獨立出去（效能最佳化）
- 延伸資料：基本資料表 + 詳細資料表

**範例：**`users` 表和 `user_profiles` 表

- `users`：存 email、密碼（頻繁查詢的核心資料）
- `user_profiles`：存生日、自介、大頭貼（較少存取的延伸資料）

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>實作方式：</b>在「延伸表」的外鍵欄位加上 <code>UNIQUE</code> 約束，確保一對一。
</div>

<!--
我們先從一對一開始。「一對一關聯：A 表的每一筆資料，對應到 B 表的恰好一筆資料。」

一對一在實務上比較少見，通常用在兩種情況。

第一種是效能考量。假設 `users` 表有五十個欄位，可是登入時只需要 email 和密碼。我們可以把自我介紹、大頭貼這些不常用的欄位，拆到 `user_profiles`，平常的查詢就只讀比較小的 `users` 表。

第二種是選填的延伸資料。不是每個人都會填個人資料，與其在 `users` 裡放一堆 NULL，不如拆出去，有填才新增。

實作的方式，是讓延伸表的外鍵不能重複。下一頁我們看寫法。
-->

---

# 一對一 SQL 範例

在 `user_profiles` 的外鍵欄位加 `UNIQUE`，實現一對一約束：

```sql
CREATE TABLE users (
  id         INT AUTO_INCREMENT,
  email      VARCHAR(255) NOT NULL UNIQUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE user_profiles (
  user_id    INT NOT NULL,
  bio        TEXT,
  avatar_url VARCHAR(500),
  birth_date DATE,
  PRIMARY KEY (user_id),
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

<!--
這段 SQL 要做的，是讓每個使用者最多只有一份個人資料。

關鍵在 `user_profiles` 裡的 `PRIMARY KEY (user_id)`。這裡把 `user_id` 同時當成主鍵和外鍵。主鍵本來就不能重複，所以每個使用者在 `user_profiles` 裡只能出現一次，一對一就成立了。這跟上一頁說的加 `UNIQUE` 是同樣的效果。

另一個重點是 `ON DELETE CASCADE`。使用者被刪除時，他的個人資料也會自動一起刪掉。這很合理，帳號都不在了，個人資料也沒有保留的必要。

執行後，每個使用者最多只會有一筆個人資料。如果對同一個使用者再新增一次，MySQL 會因為主鍵重複而拒絕。
-->

---

# 一對多（One-to-Many）

「一對多關聯：A 表的一筆資料，對應到 B 表的多筆資料。」

這是最常見的關聯類型。

**範例：**
- 一個顧客（customers）可以有多筆訂單（orders）
- 一篇文章（posts）可以有多則留言（comments）
- 一個部門（departments）有多個員工（employees）

**實作方式：**
在「多」的那張表加入外鍵，指向「一」的那張表的主鍵。

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>記憶口訣：</b>外鍵放在「多」的那邊。訂單（多）有 customer_id，指向顧客（一）。
</div>

<!--
接著是最重要的一對多。「一對多關聯：A 表的一筆資料，對應到 B 表的多筆資料。」

怎麼判斷呢？可以從兩個方向各問一次。一個顧客可以有幾筆訂單？很多筆。一筆訂單屬於幾個顧客？只有一個。這就是一對多。

實作的關鍵只有一句話：「外鍵放在多的那邊。」所以是訂單表裡放 `customer_id`，而不是顧客表裡放 `order_id`。

如果反過來，在顧客表放一個 `order_id`，每個顧客就只能記一筆訂單，根本表達不了「很多筆」。這是初學者很常搞反的地方。
-->

---

# 一對多 SQL 範例

一個顧客可以有多筆訂單，`customer_id` 外鍵放在 `orders` 表：

```sql
CREATE TABLE customers (
  id         INT AUTO_INCREMENT,
  name       VARCHAR(100) NOT NULL,
  email      VARCHAR(255) NOT NULL UNIQUE,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE orders (
  id          INT AUTO_INCREMENT,
  customer_id INT NOT NULL,
  total       DECIMAL(10,2) NOT NULL,
  order_date  DATE NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (customer_id) REFERENCES customers(id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

<!--
這是最標準的一對多寫法。

`customers` 是一的那邊，`orders` 是多的那邊。外鍵 `customer_id` 放在 `orders` 裡，透過 `REFERENCES customers(id)` 指向顧客的主鍵。

後面的 `ON DELETE RESTRICT`，表示顧客還有訂單時，MySQL 會拒絕刪除這個顧客。這是最安全的設定，可以避免不小心刪掉還有關聯資料的顧客。

執行後，我們新增一筆訂單，只要把 `customer_id` 填成 1，這筆訂單就屬於一號顧客。之後要查顧客和他的所有訂單，就用 `customer_id` 把兩張表 JOIN 起來，這個查詢我們之後在 JOIN 那一章會詳細練習。
-->

---

# 多對多（Many-to-Many）

「多對多關聯：A 表的多筆資料，可以對應 B 表的多筆資料；反之亦然。」

**範例：**
- 學生（students）和課程（courses）：一個學生選多門課，一門課有多個學生
- 訂單（orders）和商品（products）：一筆訂單包含多種商品，一種商品出現在多筆訂單
- 文章（posts）和標籤（tags）：一篇文章有多個標籤，一個標籤有多篇文章

**實作方式：**
無法直接用外鍵表達！需要建立一張**中介表（Junction Table）**，把多對多分解成兩個一對多。

<!--
最後一種是多對多。「多對多關聯：A 表的多筆資料，可以對應 B 表的多筆資料；反之亦然。」學生和課程、訂單和商品、文章和標籤，都是多對多。

多對多最常見的錯誤，是在 `students` 裡加一個欄位，用逗號把好幾個課程編號串在一起。這違反了 1NF，查詢和修改都很麻煩。

多對多沒辦法只靠一個外鍵表達。正確做法是建立一張「中介表」，讓它的每一筆資料代表「某個學生選了某門課」這件事。這樣多對多就被拆成兩個一對多，學生對選課記錄、課程對選課記錄。

這部分我們在第三段會詳細實作。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第二部分
# 用 FOREIGN KEY 實作關聯

<!--
認識三種關聯之後，接下來深入 FOREIGN KEY 的語法，尤其是父表資料被刪除或修改時，子表要怎麼反應。
-->

---

# FOREIGN KEY 的語法結構

```sql
CREATE TABLE child_table (
  id          INT AUTO_INCREMENT,
  parent_id   INT NOT NULL,
  other_col   VARCHAR(100),
  PRIMARY KEY (id),
  FOREIGN KEY (parent_id)
    REFERENCES parent_table(id)
    ON DELETE [RESTRICT | CASCADE | SET NULL | NO ACTION]
    ON UPDATE [RESTRICT | CASCADE | SET NULL | NO ACTION]
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>注意：</b>FOREIGN KEY 必須搭配 <code>ENGINE=InnoDB</code>，MyISAM 引擎不支援外鍵約束。
</div>

<!--
這是 FOREIGN KEY 的完整語法結構，`FOREIGN KEY` 後面接子表的欄位，`REFERENCES` 後面接父表和欄位。

寫的時候有三個重點。第一，子表的外鍵欄位和父表被參照的欄位，型別必須一致，例如都是 `INT`，不然 MySQL 會報錯。第二，被參照的欄位必須是主鍵，或是有 `UNIQUE` 約束。第三，要用 InnoDB 引擎，MyISAM 不支援外鍵。

最下面的 `ON DELETE` 和 `ON UPDATE`，就是父表資料被刪除或修改時，子表的處理方式。方括號裡列了四種選項，這也是外鍵設定裡最重要的部分，我們下一頁一個一個看。
-->

---

# ON DELETE / ON UPDATE 選項

當父表記錄被刪除或主鍵被更新時，子表的對應行為：

| 選項 | 行為 | 適用場景 |
| --- | --- | --- |
| `RESTRICT` | 拒絕操作，報錯（預設）| 需要保護資料的情況 |
| `CASCADE` | 自動連帶刪除或更新子表記錄 | 父子資料生命週期一致 |
| `SET NULL` | 將外鍵欄位設為 NULL | 子記錄可以存在但不需要父記錄 |
| `NO ACTION` | 同 RESTRICT（InnoDB 中行為相同）| 與 RESTRICT 幾乎等價 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
⚠️ <b>注意：</b>使用 <code>SET NULL</code> 時，外鍵欄位必須允許 NULL（不能有 NOT NULL 約束）。
</div>

<!--
表格列出四種選項，我們用「刪除父表資料時，子表怎麼辦」來理解。

`RESTRICT` 是最安全的。只要還有子表資料參照它，就直接拒絕刪除。

`CASCADE` 是連帶處理。刪掉父表資料，所有參照它的子表資料也一起刪掉。適合生命週期一致的資料，但要小心，一個刪除可能牽連出大量資料。

`SET NULL` 是保留子表資料，只把外鍵改成 NULL。適合子資料自己還有意義的情況。要注意，這時外鍵欄位不能設 `NOT NULL`。

`NO ACTION` 在 InnoDB 裡的行為和 `RESTRICT` 一樣，大家知道就好。
-->

---

# ON DELETE / ON UPDATE 範例

三種選項的完整 SQL 範例：

```sql
-- CASCADE：刪除顧客時，連帶刪除他的所有留言
FOREIGN KEY (user_id) REFERENCES users(id)
  ON DELETE CASCADE

-- RESTRICT：有訂單的顧客不能刪除（預設，最安全）
FOREIGN KEY (customer_id) REFERENCES customers(id)
  ON DELETE RESTRICT ON UPDATE CASCADE

-- SET NULL：員工離職後，訂單的 assigned_to 設為 NULL
FOREIGN KEY (assigned_to) REFERENCES employees(id)
  ON DELETE SET NULL
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>最常用組合：</b><code>ON DELETE RESTRICT ON UPDATE CASCADE</code> — 防止意外刪除，但允許主鍵更新時自動同步。
</div>

<!--
這頁把三種常用選項放進實際情境裡。

第一個是 `CASCADE`。使用者帳號刪除時，他的留言也一起刪掉，因為沒有帳號的留言已經沒有意義。

第二個是 `RESTRICT`。在電商系統裡，訂單是重要的財務紀錄，所以有訂單的顧客不能直接刪除，要先處理他的訂單。後面搭配 `ON UPDATE CASCADE`，如果顧客的主鍵被修改，訂單裡的外鍵會自動同步，雖然實務上主鍵很少被改。

第三個是 `SET NULL`。員工離職被刪除後，他負責的訂單還在，只是 `assigned_to` 變成 NULL，表示目前沒有負責人。

最常用的組合，就是畫面下方的 `ON DELETE RESTRICT ON UPDATE CASCADE`，既防止誤刪，又能自動同步更新。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第三部分
# 多對多的實作

<!--
FOREIGN KEY 的選項清楚了，接下來回到最容易卡住的多對多，一步一步把它設計出來。
-->

---

# 中介表（Junction Table）的概念

「解決多對多的唯一辦法，就是建立一張中介表，把多對多分解成兩個一對多。」

多對多的原始需求：

- 一個學生可以選多門課
- 一門課可以被多個學生選修

透過中介表分解：

- `students` → `enrollments`：一對多（一個學生有多筆選課記錄）
- `courses` → `enrollments`：一對多（一門課有多筆選課記錄）

中介表 `enrollments` 的每一筆記錄，代表「某個學生選了某門課」這件事。

<!--
中介表的想法其實很直覺。既然兩張表沒辦法直接表達多對多，我們就多加一張表，專門記錄每一次的連結。

這就像圖書館的借閱登記簿。讀者和書是多對多，一個人會借很多本，一本書也會被很多人借過。圖書館不會在書上寫滿讀者的名字，而是用一本登記簿，每一行記錄「誰借了哪本書」。

`enrollments` 就是這本登記簿，每一筆代表「某個學生選了某門課」。這樣就把多對多拆成學生對選課記錄、課程對選課記錄，兩個一對多。

中介表還可以存放這段關係本身的屬性，例如選課日期、成績。這些資料同時需要學生和課程才能決定，放在中介表剛剛好。
-->

---

# 多對多 SQL 範例 — 學生選課（Part 1）

先建立 `students` 和 `courses` 兩張實體表：

```sql
CREATE TABLE students (
  id         INT AUTO_INCREMENT,
  name       VARCHAR(100) NOT NULL,
  student_no VARCHAR(20)  NOT NULL UNIQUE,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE courses (
  id          INT AUTO_INCREMENT,
  course_name VARCHAR(100) NOT NULL,
  credits     TINYINT      NOT NULL DEFAULT 3,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

<!--
實作的第一步，是先建立兩張實體表。

`students` 存學生的基本資料，`student_no` 加了 `UNIQUE`，確保學號不重複。`courses` 存課程資料，`credits` 預設是三學分。

兩張表都用 `INT AUTO_INCREMENT` 當主鍵，這樣中介表參照起來最簡單。

執行後會得到兩張獨立的表。要特別注意，這兩張表彼此之間沒有任何外鍵，它們的關係完全交給下一步的中介表 `enrollments` 來建立。
-->

---

# 多對多 SQL 範例 — 學生選課（Part 2）

建立中介表 `enrollments`，連接 students 和 courses：

```sql
CREATE TABLE enrollments (
  student_id  INT  NOT NULL,
  course_id   INT  NOT NULL,
  grade       DECIMAL(4,1),
  enrolled_at DATE NOT NULL DEFAULT (CURRENT_DATE),
  PRIMARY KEY (student_id, course_id),
  FOREIGN KEY (student_id) REFERENCES students(id)
    ON DELETE CASCADE,
  FOREIGN KEY (course_id) REFERENCES courses(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

<!--
第二步，建立中介表 `enrollments`，把學生和課程連起來。

第一個關鍵行是 `PRIMARY KEY (student_id, course_id)`。用學號和課程組成複合主鍵，同一個學生就不能重複選同一門課。

第二個關鍵是兩個 `FOREIGN KEY`，一個指向 `students`，一個指向 `courses`。這就是「把多對多拆成兩個一對多」的實際寫法。

`grade` 和 `enrolled_at` 是這段選課關係的屬性。成績要同時知道學生和課程才能決定，放在中介表是正確的。

兩個外鍵都設了 `ON DELETE CASCADE`。執行後，學生被刪除時，他的選課記錄會一起刪掉；課程被刪除時，所有人選這門課的記錄也會一起刪掉。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第四部分
# 關聯設計注意事項

<!--
最後一部分，我們整理三個實務上常踩的坑，先有印象，遇到時就知道怎麼處理。
-->

---

# 注意一：外鍵欄位要加 INDEX

InnoDB 建立外鍵時，若欄位沒有索引會自動建立；建議明確寫出來，名稱和用途更清楚：

```sql
CREATE TABLE orders (
  id          INT AUTO_INCREMENT,
  customer_id INT NOT NULL,
  order_date  DATE NOT NULL,
  PRIMARY KEY (id),
  INDEX idx_customer_id (customer_id),
  FOREIGN KEY (customer_id) REFERENCES customers(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
⚠️ <b>效能陷阱：</b>JOIN 用到的欄位如果沒有 INDEX，就可能需要全表掃描。資料量大時速度會非常慢！
</div>

<!--
第一個注意事項是效能。JOIN 的時候，MySQL 要在 `orders` 裡找出某個 `customer_id` 的所有訂單。如果這個欄位沒有索引，就得把整張表從頭掃到尾，資料一多就會非常慢。

畫面上的寫法，是用 `INDEX idx_customer_id (customer_id)` 這一行明確幫外鍵建立索引。

這裡要注意一個細節。InnoDB 在建立外鍵時，如果欄位還沒有索引，會自動幫我們建一個。不過明確寫出來，讀程式的人一眼就看得懂，索引名稱也由我們自己決定，更清楚。

所以養成一個習慣：外鍵欄位都明確加上 INDEX。
-->

---

# 注意二：表的建立順序

「被參照的表，必須先建立。」

| 情境 | 正確順序 |
| --- | --- |
| orders 參照 customers | 先建 customers，再建 orders |
| enrollments 參照 students 和 courses | 先建 students 和 courses，再建 enrollments |
| 循環相依（A 參照 B，B 也參照 A）| 先建表，再用 ALTER TABLE 加外鍵 |

```sql
-- 循環相依的解法：先建表，後加外鍵
CREATE TABLE departments (id INT PRIMARY KEY, manager_id INT);
CREATE TABLE employees (id INT PRIMARY KEY, dept_id INT,
  FOREIGN KEY (dept_id) REFERENCES departments(id));
ALTER TABLE departments
  ADD FOREIGN KEY (manager_id) REFERENCES employees(id);
```

<!--
第二個注意事項是建立順序：「被參照的表，必須先建立。」

如果先建 `orders`，可是它參照的 `customers` 還不存在，MySQL 就會報錯。所以要先建父表，再建有外鍵的子表。

比較麻煩的是循環相依，也就是兩張表互相參照。例如部門表記錄主管是哪個員工，員工表又記錄自己屬於哪個部門。這時候不管先建哪一張都會卡住。

解法就是下面這段 SQL。先建 `departments`，暫時不加外鍵。接著建 `employees`，讓它參照部門。最後再用 `ALTER TABLE` 幫部門表補上主管的外鍵。

反過來刪除表的時候，順序也相反，要先刪子表，再刪父表。
-->

---

# 注意三：常見設計錯誤

| 錯誤 | 問題 | 正確做法 |
| --- | --- | --- |
| 用逗號分隔存多個外鍵值 | 違反 1NF，無法用索引查詢 | 建立中介表（多對多）|
| 外鍵欄位型別不一致 | MySQL 報錯，無法建立 FOREIGN KEY | 父子表的相關欄位型別必須完全一致 |
| 關聯欄位沒有 INDEX（如未宣告外鍵）| JOIN 時可能全表掃描，效能低落 | 關聯欄位明確加 INDEX |
| 使用 MyISAM 引擎 | 外鍵語法不報錯但完全不起作用 | 改用 InnoDB |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
⚠️ <b>特別注意：</b>MyISAM 引擎會接受 FOREIGN KEY 語法，但完全不會執行約束。這是一個很隱蔽的陷阱！
</div>

<!--
這張表整理了四個常見的設計錯誤。用逗號存多個值要改成中介表，外鍵型別要和父表一致，外鍵欄位要加索引，這些前面都提過了。

這裡特別要講的是 MyISAM。如果建表時用了 MyISAM 引擎，我們寫的 FOREIGN KEY 語法不會報錯，MySQL 也會接受，可是它完全不會檢查約束。

這代表我們以為有外鍵保護，其實什麼都沒有，任何不存在的 `customer_id` 都能被新增進去。這個陷阱很隱蔽，平常完全看不出來。

MySQL 8 的預設引擎已經是 InnoDB，不過維護舊專案時一定要檢查。最保險的習慣，是建表時明確寫上 `ENGINE=InnoDB`。
-->

---

# 總結

本章學了資料表關聯設計的核心知識：

- **三種關聯類型** — 一對一（UNIQUE 外鍵）、一對多（外鍵在多的那邊）、多對多（中介表）
- **FOREIGN KEY 語法** — REFERENCES、ON DELETE、ON UPDATE 四種選項
- **選項選擇** — RESTRICT（安全預設）/ CASCADE（連帶刪除）/ SET NULL（保留子記錄）
- **多對多實作** — 中介表分解兩個一對多，中介表可存關聯屬性（如成績）
- **注意事項** — 外鍵加 INDEX、注意建立順序、使用 InnoDB 引擎

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
🚀 <b>下一章：</b>有了設計基礎，我們開始學 DDL，用 SQL 把這些精心設計的資料表真正建立起來！
</div>

<!--
我們來整理這一章。關聯有三種：一對一可以用主鍵或 `UNIQUE` 的外鍵，一對多是外鍵放在多的那邊，多對多要用中介表拆成兩個一對多。

外鍵的連動選項裡，`RESTRICT` 是安全的預設，`CASCADE` 會連帶處理，`SET NULL` 會保留子資料。實務上還要記得幫外鍵加索引、注意建表順序，以及使用 InnoDB。

到這裡，前三章的設計基礎就完整了。接下來我們先用兩題練習把關聯設計練熟，之後就要正式開始寫 SQL，先從建立資料表開始。
-->

---
layout: default
---

# 練習 1：任務說明
### 設計動態問卷系統的資料庫

後面的課程會做一套「動態問卷系統」，資料庫就從這裡開始設計：

- 一份問卷（surveys）有多個題目（questions），題目有多個選項（options）
- 會員（users）可以填寫多份問卷，也允許**未登入**的訪客填寫
- 每次填寫是一筆作答紀錄（survey_responses），底下有每一題的答案（response_answers）
- 同一份問卷、同一個 Email 只能填寫一次

**任務：**
1. 識別每組關聯的類型（一對一、一對多或多對多）
2. 設計所有必要的資料表與外鍵，並決定 `ON DELETE` 行為
3. 用約束保證「同一 Email 不能重複填寫同一份問卷」

<!--
接下來的練習，都會圍繞同一個專案：動態問卷系統。後面的章節也會繼續用到這裡設計的資料表。

這題有六張表要設計。請大家先找出每組關聯的類型，再決定外鍵放在哪裡，刪除時又該怎麼處理。

思考一下，訪客不用登入也能填寫，那作答紀錄裡的 `user_id` 可以設成 NOT NULL 嗎？

我們先暫停一下，自己動手設計看看。

【講師】給大家十到十五分鐘，可以先請同學在白板上畫出六張表的關聯。
-->

---
layout: default
---

# 練習 1：解題提示（Part 1）

`surveys` 是最上層的表，先把問卷本身的資料存好：

```sql
CREATE TABLE surveys (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  title       VARCHAR(50) NOT NULL,
  description VARCHAR(300),
  start_date  DATE NOT NULL,
  end_date    DATE NOT NULL,
  published   TINYINT NOT NULL DEFAULT 0,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>「進行中 / 已結束」不存進資料庫。</b>狀態可以由日期算出來，存成欄位反而會過期。
</div>

<!--
我們從最上層的問卷開始。`surveys` 不參照別的表，只存問卷本身的資料。

這裡有個重要的設計決定。問卷的進行中或已結束，我們沒有存成欄位。因為這個狀態每天都可能改變，存起來就得天天更新，很容易出錯。

所以我們只存有沒有發佈，以及起訖日期，狀態等查詢時再算出來。怎麼算，後面查詢的章節會練習到。
-->

---
layout: default
---

# 練習 1：解題提示（Part 1 續）

`surveys` 到 `questions` 是一對多，外鍵放在「多」的那邊：

```sql
CREATE TABLE questions (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  survey_id   INT NOT NULL,
  title       VARCHAR(200) NOT NULL,
  type        VARCHAR(10) NOT NULL,
  required    TINYINT NOT NULL DEFAULT 0,
  order_index INT NOT NULL,
  INDEX idx_questions_survey (survey_id),
  FOREIGN KEY (survey_id) REFERENCES surveys(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

<!--
接著是題目。一份問卷有很多題目，這是一對多，所以外鍵 `survey_id` 放在 `questions` 這邊。

外鍵用 `ON DELETE CASCADE`。問卷刪掉之後，它的題目也沒有意義了，就一起刪除。

`order_index` 用來記錄畫面上的順序。資料表本身不保證順序，想固定順序就要自己存一個欄位。
-->

---
layout: default
---

# 練習 1：解題提示（Part 1 續）

`options` 也一樣，外鍵放在「多」的那邊：

```sql
CREATE TABLE options (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  question_id INT NOT NULL,
  label       VARCHAR(100) NOT NULL,
  order_index INT NOT NULL,
  INDEX idx_options_question (question_id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

<!--
一個題目也有很多選項，同樣是一對多，外鍵放在 `options`。

文字題沒有選項，只要在這張表裡沒有對應的資料列就好，不需要另外處理。

到這裡，問卷、題目和選項這三層就串起來了。
-->



---
layout: default
---

# 練習 1：解題提示（Part 2）

`users` 存會員資料，`email` 不可重複：

```sql
CREATE TABLE users (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(50) NOT NULL,
  email      VARCHAR(100) NOT NULL UNIQUE,
  password   VARCHAR(100) NOT NULL,
  phone      VARCHAR(20),
  role       VARCHAR(10) NOT NULL DEFAULT 'USER',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

<!--
再來是會員。`users` 也不參照別的表，重點是 `email` 加上 `UNIQUE`，同一個 Email 不能註冊兩次。

`role` 用來區分一般會員和管理員，預設是一般會員。

`password` 的長度給到一百，因為之後存的不是密碼原文，而是加密過的雜湊字串，長度會比原本的密碼長很多。
-->

---
layout: default
---

# 練習 1：解題提示（Part 2 續）

訪客免登入，所以 `user_id` 可以是 `NULL`：

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
  FOREIGN KEY (survey_id) REFERENCES surveys(id)
    ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

<!--
作答紀錄把姓名、手機和 Email 直接存在自己身上，因為訪客沒有會員資料可以關聯。這也回答了剛才的思考題，`user_id` 不能是 NOT NULL。

刪除會員時用 `SET NULL`。帳號刪掉了，作答資料還是要保留，只是變成匿名。

重點是 `UNIQUE KEY (survey_id, email)`。這是複合唯一，同一份問卷同一個 Email 只能有一筆，換一份問卷就可以再填。
-->

---
layout: default
---

# 練習 1：解題提示（Part 3）

`response_answers` 同時參照「哪一次作答」與「哪一道題」：

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

<div class="mt-4 p-3 bg-yellow-50 border-l-4 border-yellow-400 text-gray-700 text-sm text-left">
⚠️ <b>取捨：</b>多選答案用分號串接，例如 <code>青菜;滷蛋</code>。嚴格說這違反 1NF，這裡是為了讓表結構簡單，代價是統計時要拆字串。
</div>

<!--
最後是每一題的答案。一次作答有很多題的答案，一道題也有很多人的答案，所以這張表有兩個外鍵。它還存了答案內容，所以用自己的 `id` 當主鍵。

這裡要老實說一個取捨。多選題的答案用分號串成一個字串，其實違反了第一正規化。我們的規格選擇這樣做，好處是一題一列、結構簡單，壞處是統計時要把字串拆開。

設計本來就常有取捨，重要的是知道自己放棄了什麼。
-->

---
layout: default
---

# 練習 2：任務說明
### 分析並修正問卷資料表設計

請從設計、資料型別、引擎、外鍵行為、約束，找出至少五個問題並修正：

```sql
CREATE TABLE survey (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  title      VARCHAR(50),
  questions  TEXT,         -- 存成 'Q1;Q2;Q3'
  published  VARCHAR(5),   -- 存成 'yes' / 'no'
  start_date VARCHAR(10),  -- 存成 '2025/01/10'
  end_date   VARCHAR(10)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE survey_answer (
  id        INT AUTO_INCREMENT PRIMARY KEY,
  survey_id INT NOT NULL,
  email     VARCHAR(100),
  answers   TEXT,          -- 存成 'A;B;C;D'
  FOREIGN KEY (survey_id) REFERENCES survey(id)
) ENGINE=MyISAM;
```

<!--
第二題換個角度，我們來當審查的人。畫面上是一位新手設計的問卷資料表，看起來能用，其實問題不少。

請大家從設計、資料型別、引擎、外鍵行為和約束這幾個方向，找出至少五個問題，並想想該怎麼修正。

思考一下，如果要修改第二題的題目名稱，或是統計第二題有多少人選 B，這個設計做得到嗎？

我們先暫停一下，自己找找看。

【講師】給大家五到十分鐘，可以請同學輪流說出找到的問題。
-->

---
layout: default
---

# 練習 2：解題提示

| 問題 | 說明 | 修正 |
| --- | --- | --- |
| `questions TEXT` 存 `Q1;Q2;Q3` | 違反 1NF，也無法設定題型、必填 | 拆成 `questions`、`options` |
| `answers TEXT` 串起整份答案 | 無法統計單一題目的結果 | 改成 `response_answers`，一題一列 |
| `published VARCHAR(5)` | 字串容易打錯，也佔空間 | 改用 `TINYINT`（0 / 1） |
| `start_date VARCHAR(10)` | 無法做日期比較，也沒有格式檢查 | 改用 `DATE` |

<!--
前四個問題都和設計與型別有關。

最值得討論的是 `answers` 這一欄。整份答案串成一個字串，看起來省事，卻沒辦法回答第二題有多少人選 B，而這正是後台統計頁要做的事。

這也回答了剛才的思考題。題目和答案都塞在一個欄位裡，要修改或統計其中一題都很困難，所以要拆成獨立的資料表。

日期存成字串也一樣，沒辦法正確比較先後，也擋不住格式錯誤的資料。
-->

---
layout: default
---

# 練習 2：解題提示（續）

| 問題 | 說明 | 修正 |
| --- | --- | --- |
| `ENGINE=MyISAM` | FOREIGN KEY 不起作用 | 改用 `ENGINE=InnoDB` |
| `CHARSET=utf8` | 不支援 emoji 等 4-byte 字元 | 改用 `utf8mb4` |
| 沒有 `UNIQUE (survey_id, email)` | 同一人可以重複填寫 | 加上複合唯一約束 |
| 外鍵沒有 `ON DELETE`、沒明確加 `INDEX` | 行為與意圖都不清楚 | 明確指定 `CASCADE`，並加上 `INDEX` |

<!--
後面四個問題和引擎與約束有關。

用了 MyISAM，外鍵語法不會報錯，卻完全不起作用，這就是剛才提過的隱蔽陷阱。

唯一約束也很容易漏掉。程式雖然可以先查一次有沒有填過，但兩個請求同時進來時，可能都查到沒填過。資料庫的唯一約束才擋得住這種情況。

我們這裡一共列了八個問題，大家找到幾個呢？關聯設計到這裡就練完了，這六張表下一章會真正建立起來。
-->

---
layout: end
---

# Q & A

有任何問題嗎？

<!--
今天我們學會了一對一、一對多、多對多三種關聯，知道外鍵要放在多的那邊，多對多要靠中介表，也比較了 `RESTRICT`、`CASCADE`、`SET NULL` 這幾種刪除行為。

到這裡，我們已經有能力設計一個正規化、而且關聯約束完整的資料庫了。從下一章開始，我們要正式動手寫 SQL，先從建立和修改資料表開始。我們下一章見。

【講師】開放提問，特別可以確認大家是否清楚各種 ON DELETE 選項的使用時機。
-->
