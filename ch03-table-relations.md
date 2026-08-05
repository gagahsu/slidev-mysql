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
大家好，歡迎來到第三章——資料表關聯設計！

前兩章我們學了設計原則和正規化，知道了「把不同的事情存在不同的表」。

但問題來了：表拆開之後，怎麼把它們連起來？

這章就是要回答這個問題。我們會學三種關聯類型，以及如何用 FOREIGN KEY 在 MySQL 中實作它們。
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
這章的結構很清楚。

先認識三種關聯類型——每種都有生活中的例子，很好理解。

接著學 FOREIGN KEY 的完整語法，重點是 ON DELETE 和 ON UPDATE 的選項，這在實際開發中非常重要。

多對多是最容易搞錯的，我們會特別花一個部分說清楚。

最後講注意事項，這些是實際工作中常踩到的坑。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第一部分
# 關聯的種類

<!--
進入第一部分，認識三種關聯類型。

每一種我都會先給一個生活中的場景，讓大家先有直覺感受，再說技術定義。
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
資料表關聯是資料庫設計的核心概念。

現實世界中的事物之間有各種關係：一個人只有一個護照（一對一），一個部門有多個員工（一對多），一個訂單可以包含多種商品、一種商品也可以出現在多筆訂單裡（多對多）。

我們的工作就是用資料表和 FOREIGN KEY 把這些關係準確地表達出來。

在這三種關聯中，「一對多」是最常見的，也是最重要的。一旦學會了一對多，其他兩種都很容易理解。
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
一對一關聯在實際應用中相對少見，但有它的使用場景。

最常見的場景是效能最佳化：假設 users 表有 50 個欄位，每次查詢都載入這 50 個欄位會很慢。我們可以把不常查詢的欄位（例如自介、大頭貼）獨立成 user_profiles 表，這樣大部分查詢只需要讀取 users 表，速度更快。

另一個場景是「可選的延伸資料」：不是每個使用者都有填寫個人資料，與其在 users 表裡放很多 NULL 值，不如把這些選填的欄位獨立成一張表，只在有資料時才插入。
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
看這個設計，重點在 user_profiles 表的 PRIMARY KEY (user_id)。

這裡我們把 user_id 同時設為主鍵和外鍵。因為主鍵的值是唯一的，所以每個 user_id 在 user_profiles 裡只能出現一次——這就確保了一對一關係。

ON DELETE CASCADE 的效果：當 users 表的某個使用者被刪除時，對應的 user_profiles 記錄也會自動刪除。這很合理，因為使用者帳號不存在了，個人資料也沒有保留的必要。

執行後：每個 users 裡的使用者，在 user_profiles 裡最多只有一筆對應的個人資料。
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
一對多是最重要的關聯類型，大家一定要記住。

怎麼判斷是一對多？問自己：A 的一筆資料可以對應 B 的幾筆？B 的一筆資料可以對應 A 的幾筆？

以顧客和訂單為例：一個顧客可以有多筆訂單（一對多）；一筆訂單只屬於一個顧客（多對一的方向看）。

實作的關鍵：外鍵放在「多」的那邊。這也是為什麼我們說「orders 表裡有 customer_id」，而不是「customers 表裡有 order_id」——後者的話，一個顧客只能有一筆訂單（一對一），無法支援多筆訂單。
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
這是最標準的一對多設計。

customers 表是「一」的那邊，orders 表是「多」的那邊。外鍵 customer_id 放在 orders 表，指向 customers 表的主鍵 id。

執行 INSERT INTO orders (customer_id, total, order_date) VALUES (1, 999.00, '2024-01-15') 後，訂單就和顧客 #1 建立了關聯。

ON DELETE RESTRICT：如果想刪除一個還有訂單的顧客，MySQL 會拒絕。這是最安全的設定，防止意外刪除有關聯資料的父表記錄。

查詢顧客和他的所有訂單：SELECT c.name, o.total FROM customers c JOIN orders o ON c.id = o.customer_id。
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
多對多是三種關聯中最容易搞錯的。

常見的錯誤是：在 students 表裡加一個 course_ids 欄位（用逗號分隔）。但這違反了 1NF，也讓查詢和維護變得非常麻煩。

正確的做法是建立一張中介表。中介表的每一筆資料代表「一個學生選了一門課」這件事。

透過中介表，我們把一個多對多關係，分解成兩個一對多：
- students 對 enrollments（一對多）
- courses 對 enrollments（一對多）

這是解決多對多的標準做法。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第二部分
# 用 FOREIGN KEY 實作關聯

<!--
認識了三種關聯類型，接下來我們深入學習 FOREIGN KEY 的語法。

重點是 ON DELETE 和 ON UPDATE 的選項，這決定了當父表資料被刪除或更新時，子表的行為。
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
FOREIGN KEY 的語法不複雜，但有幾個關鍵點要注意。

第一：子表的外鍵欄位（parent_id）和父表的被參照欄位（id）資料型別必須一致，否則 MySQL 會報錯。

第二：被參照的欄位（父表的 id）必須是 PRIMARY KEY 或有 UNIQUE 約束。

第三：InnoDB 引擎才支援 FOREIGN KEY。CREATE TABLE 時記得加上 ENGINE=InnoDB。

最重要的是 ON DELETE 和 ON UPDATE 的選項，我們下一張投影片詳細說明。
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
ON DELETE 選項是最重要的設定，決定了「刪除父表資料時，子表怎麼辦」。

RESTRICT 是最安全的預設值。它說：「如果這筆父表記錄還有子表資料在參照它，就拒絕刪除。」這能防止意外刪除有關聯的資料。

CASCADE 說：「刪父表記錄時，所有參照它的子表記錄也一起刪。」這在「父子生命週期一致」的場景很方便——例如刪除一個使用者帳號時，連帶刪除他的所有訂單和評論。但要小心，CASCADE 可能導致大量資料被刪除！

SET NULL 說：「刪父表記錄時，子表的外鍵設為 NULL。」適合「子記錄仍然有意義，只是暫時沒有關聯父記錄」的場景，例如員工離職後訂單記錄仍需保留但關聯的員工為 NULL。
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
這三個範例涵蓋了最常見的三種使用場景。

第一個 CASCADE：使用者帳號刪除時，他的所有留言也一起刪除。這很合理，因為沒有帳號的留言是無意義的。

第二個 RESTRICT：有訂單的顧客不能被刪除。在電商系統裡，訂單記錄是重要的財務資料，必須保留，所以顧客帳號的刪除需要先處理相關訂單。ON UPDATE CASCADE 讓主鍵更新時外鍵自動同步（雖然主鍵通常不會更新）。

第三個 SET NULL：員工離職後，他負責的訂單的 assigned_to 欄位設為 NULL，訂單本身繼續存在，只是不再有對應的負責人。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第三部分
# 多對多的實作

<!--
多對多是這章的重點難點。

很多初學者在遇到多對多時，要嘛想在欄位裡塞多個值（違反 1NF），要嘛不知道怎麼辦。

我們用一個具體的例子，一步一步把多對多設計清楚。
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
中介表的思路很直觀：既然不能在兩張表之間直接建立多對多，我們就加一張表來「記錄每一個關聯」。

enrollments 表的每一筆資料就是一個事件：「學生 S001 在某個時間選了課程 C001」。

這張中介表的主鍵通常是複合主鍵 (student_id, course_id)，確保同一個學生不會重複選同一門課。

中介表也可以存放關聯的「屬性」——例如選課日期、成績、出勤次數等，這些屬性同時相依於學生和課程（符合 2NF）。
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
第一步：建立兩張實體表。

students 表存學生的基本資料，courses 表存課程的基本資料。

這兩張表本身沒有直接的關聯，它們之間的關係會透過下一步的中介表 enrollments 來建立。

注意：兩張表都使用 INT AUTO_INCREMENT 作為主鍵，這是實作多對多時最簡潔的設計。
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
這是中介表的設計。

複合主鍵 (student_id, course_id) 確保同一個學生不能重複選同一門課。

enrollments 表有兩個 FOREIGN KEY：一個指向 students，一個指向 courses。這就是「把多對多分解成兩個一對多」的技術實作。

grade 欄位是「選課關係的屬性」——它同時需要 student_id 和 course_id 才能確定，符合 2NF，所以放在中介表裡是正確的。

兩個 FOREIGN KEY 都設了 ON DELETE CASCADE：當學生被刪除時，她的所有選課記錄也一起刪除；當課程被刪除時，所有選了這門課的記錄也一起刪除。

查詢某學生的所有課程：SELECT s.name, c.course_name FROM students s JOIN enrollments e ON s.id = e.student_id JOIN courses c ON e.course_id = c.id WHERE s.id = 1。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第四部分
# 關聯設計注意事項

<!--
最後一部分，我們來說幾個實際工作中容易踩到的坑。

這些不是理論，都是真實的問題，大家先有個印象，以後遇到時就知道怎麼處理。
-->

---

# 注意一：外鍵欄位要加 INDEX

MySQL 不會自動在外鍵欄位建立索引（除非是主鍵），但 JOIN 時非常需要：

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
⚠️ <b>效能陷阱：</b>沒有 INDEX 的外鍵欄位，每次 JOIN 都需要全表掃描。資料量大時速度會非常慢！
</div>

<!--
這是一個很多初學者會忽略的效能問題。

當你執行 SELECT * FROM orders JOIN customers ON orders.customer_id = customers.id 時，MySQL 需要在 orders 表裡找出所有 customer_id = 特定值的記錄。

如果 customer_id 沒有索引，MySQL 要掃描整張 orders 表——這在資料量大的時候會非常慢。

幸好，InnoDB 引擎在建立 FOREIGN KEY 時，如果對應欄位還沒有索引，會自動建立一個。但這個行為不是 MySQL 標準規範的一部分，顯式地用 INDEX 關鍵字定義更安全、也更清楚。

養成習慣：外鍵欄位一定加 INDEX。
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
建立順序的問題是初學者最常踩的坑之一。

如果你先建 orders 表，但 orders 表的 FOREIGN KEY 參照了 customers 表，而 customers 表還不存在，MySQL 會報錯。

解決方法很簡單：永遠先建被參照的表（父表），再建有外鍵的表（子表）。

但有時候兩張表互相參照（循環相依），例如「部門表記錄主管（是員工），員工表記錄所屬部門」。這種情況就需要先建表（不加外鍵），再用 ALTER TABLE 補上外鍵。

⚠️ 刪除表時順序相反：先刪子表（有外鍵的），再刪父表（被參照的）。
-->

---

# 注意三：常見設計錯誤

| 錯誤 | 問題 | 正確做法 |
| --- | --- | --- |
| 用逗號分隔存多個外鍵值 | 違反 1NF，無法用索引查詢 | 建立中介表（多對多）|
| 外鍵欄位型別不一致 | MySQL 報錯，無法建立 FOREIGN KEY | 父子表的相關欄位型別必須完全一致 |
| 忘記加 INDEX | JOIN 時全表掃描，效能低落 | 外鍵欄位一定加 INDEX |
| 使用 MyISAM 引擎 | 外鍵語法不報錯但完全不起作用 | 改用 InnoDB |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
⚠️ <b>特別注意：</b>MyISAM 引擎會接受 FOREIGN KEY 語法，但完全不會執行約束。這是一個很隱蔽的陷阱！
</div>

<!--
讓我特別說一下 MyISAM 的問題。

如果你建表時用了 ENGINE=MyISAM（或者沒有指定引擎，而預設是 MyISAM），你寫的 FOREIGN KEY 語法不會報錯，MySQL 會接受它，但完全不執行任何約束檢查。

這意味著你以為有外鍵保護，其實完全沒有——你可以插入任何 customer_id 值，包括不存在的顧客。

MySQL 8.x 的預設引擎是 InnoDB，所以在現代環境下這個問題比較少見。但如果你在維護舊專案，一定要檢查引擎設定。

建表時顯式加上 ENGINE=InnoDB 是最安全的習慣。
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
🚀 <b>下一章：</b>有了設計基礎，我們開始學 SELECT 查詢，探索如何從這些精心設計的資料表裡取出我們要的資料！
</div>

<!--
學完前三章，大家已經掌握了資料庫設計的完整基礎：

第一章：設計原則（PRIMARY KEY、FOREIGN KEY、命名慣例）
第二章：正規化（1NF、2NF、3NF）
第三章：關聯設計（一對一、一對多、多對多）

這三章是後續所有 SQL 查詢的基礎。設計好了資料庫，查詢才能又快又準。

接下來的章節，我們就要開始學各種 SQL 語法，實際在這些資料表上做查詢、新增、修改、刪除了！
-->

---
layout: default
---

# 練習 1：任務說明
### 設計一個部落格資料庫

你要設計一個部落格系統的資料庫，需要記錄以下關聯：

- 使用者（users）可以寫多篇文章（posts）
- 每篇文章可以有多個標籤（tags），每個標籤也可以出現在多篇文章
- 每篇文章可以有多則留言（comments），每則留言屬於一個使用者

**任務：**
1. 識別每種關聯的類型（一對一、一對多或多對多）
2. 設計所有必要的資料表，包括中介表
3. 定義適當的 FOREIGN KEY 和 ON DELETE 行為

<!--
這題包含了這章學到的三種關聯類型都出現了（一對多和多對多）。

提示一：users 和 posts 是一對多（一個使用者寫多篇文章）。

提示二：posts 和 tags 是多對多（需要中介表）。

提示三：posts 和 comments 是一對多，comments 和 users 也是一對多。

思考：ON DELETE 應該選什麼？刪除使用者時，他的文章和留言要一起刪嗎？
-->

---
layout: default
---

# 練習 1：解題提示（Part 1）

`users` 與 `posts` — 一對多，外鍵 `user_id` 放在「多」的 `posts` 表：

```sql
CREATE TABLE users (id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL, email VARCHAR(255) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE posts (id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL, title VARCHAR(200) NOT NULL, content TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_user_id (user_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>ON DELETE CASCADE：</b>刪除使用者時，他的文章也一起刪除。<code>user_id</code> 加 INDEX，JOIN 查詢才快。
</div>

<!--
解答第一部分：users 和 posts。

users ← posts 是一對多，外鍵 user_id 放在 posts 表（「多」的那邊）。

ON DELETE CASCADE 表示刪除使用者時，他的文章也一起刪。這是設計決策——如果希望文章保留（例如改成「已刪除使用者」），可以改用 SET NULL，但那樣 user_id 就不能是 NOT NULL。

⚠️ 注意：posts 表的 user_id 欄位加了 INDEX，這對 JOIN 查詢非常重要。

下一頁看多對多的部分。
-->

---
layout: default
---

# 練習 1：解題提示（Part 2）

`posts` 與 `tags` — 多對多，需要中介表 `post_tags`：

```sql
CREATE TABLE tags (id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE post_tags (post_id INT NOT NULL, tag_id INT NOT NULL,
  PRIMARY KEY (post_id, tag_id),
  FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
  FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>複合主鍵 </b><code>(post_id, tag_id)</code> — 同一篇文章不會重複掛同一個標籤。
</div>

<!--
解答第二部分：posts 和 tags 的多對多。

多對多無法直接用外鍵表達，需要中介表 post_tags，把它分解成兩個一對多。

主鍵是複合主鍵 (post_id, tag_id)，確保同一篇文章不會重複掛同一個標籤。

兩個外鍵都設 ON DELETE CASCADE：刪除文章時，文章的所有標籤關聯也一起刪；刪除標籤時，所有文章和這個標籤的關聯也一起刪（但文章本身不刪）。

下一頁補上 comments 表——它同時參照 posts 和 users。
-->

---
layout: default
---

# 練習 1：解題提示（Part 3）

`comments` — 同時參照 `posts` 和 `users`，兩個一對多：

```sql
CREATE TABLE comments (id INT AUTO_INCREMENT PRIMARY KEY,
  post_id    INT NOT NULL,
  user_id    INT,
  content    TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_post_id (post_id),
  INDEX idx_user_id (user_id),
  FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>兩個外鍵，兩種行為：</b>刪文章 → 留言一起刪（<code>CASCADE</code>）；刪使用者 → 留言保留但作者變匿名（<code>SET NULL</code>）。
</div>

<!--
解答第三部分：comments 表。

comments 不是多對多——它同時是兩個一對多的「多」邊：
- posts → comments：一篇文章有多則留言
- users → comments：一個使用者寫多則留言

所以兩個外鍵都放在 comments 表，不需要中介表。這是初學者容易搞錯的地方：看到「兩個外鍵」就以為是中介表，其實中介表的關鍵在於它的主鍵是那兩個外鍵組成的複合主鍵。

重點在兩個外鍵用了不同的 ON DELETE：

post_id 用 CASCADE：文章刪了，底下的留言就沒有意義，一起刪。

user_id 用 SET NULL：使用者帳號刪了，留言本身對其他讀者仍有價值，保留下來、作者顯示為匿名。

⚠️ 注意：要用 SET NULL，user_id 就不能有 NOT NULL 約束——所以這裡 user_id 沒有寫 NOT NULL，和 post_id 不同。

兩個外鍵欄位都加了 INDEX。
-->


---
layout: default
---

# 練習 2：任務說明
### 分析並修正 FOREIGN KEY 設計

以下是一段有問題的資料表設計，找出所有問題並修正：

```sql
CREATE TABLE orders (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  product_ids VARCHAR(200),
  total       FLOAT,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
```

**找出至少四個問題：**設計、資料型別、引擎、外鍵行為。

<!--
這題是綜合性的找錯題，把前三章學到的內容都結合在一起了。

提示一：product_ids 欄位存了什麼？違反了什麼正規化規則？

提示二：total 的資料型別適合存金額嗎？

提示三：引擎是什麼？FOREIGN KEY 有效嗎？

提示四：FOREIGN KEY 的 ON DELETE 行為是什麼？預設合理嗎？

還有 utf8 vs utf8mb4 的問題！
-->

---
layout: default
---

# 練習 2：解題提示

| 問題 | 說明 | 修正 |
| --- | --- | --- |
| `product_ids VARCHAR(200)` | 多個值塞在一個欄位，違反 1NF | 建立 `order_items` 中介表 |
| `FLOAT` 存金額 | 浮點數有精度問題 | 改用 `DECIMAL(10,2)` |
| `ENGINE=MyISAM` | FOREIGN KEY 不起作用 | 改用 `ENGINE=InnoDB` |
| 無 `ON DELETE` 指定 | 預設 RESTRICT，但應明確標示 | 加上 `ON DELETE RESTRICT` |
| `CHARSET=utf8` | 不支援 emoji 等 4-byte 字元 | 改用 `utf8mb4` |
| 缺少 `INDEX` | JOIN 效能差 | 加上 `INDEX idx_customer_id (customer_id)` |

<!--
這六個問題涵蓋了我們三章學到的所有重點。

最隱蔽的是 ENGINE=MyISAM 的問題：表面上 FOREIGN KEY 語法沒有報錯，但完全沒有執行任何約束。這是一個很難發現的 Bug，特別是在舊版 MySQL 預設引擎是 MyISAM 的環境下。

product_ids 違反 1NF，正確做法是建立 order_items 中介表：一張訂單對應多個訂單明細，每個訂單明細記錄一種商品的 product_id 和數量。

大家有沒有找到全部六個問題？
-->

---
layout: end
---

# Q & A

有任何問題嗎？

<!--
現在開放 Q&A 時間。

大家對三種關聯類型、FOREIGN KEY 的選項，還是多對多的中介表設計，有沒有什麼疑問？

特別是 ON DELETE 的四個選項（RESTRICT、CASCADE、SET NULL、NO ACTION），如果還不確定什麼時候用哪個，歡迎提問。

學完這三章，大家已經具備了設計一個正規化、有完整關聯約束的資料庫的能力。接下來的章節我們就要正式開始 SQL 查詢了！
-->
