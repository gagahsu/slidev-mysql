---
theme: penguin
class: text-center
highlighter: shiki
lineNumbers: true
transition: slide-left
title: Spring Boot 介紹
routeAlias: ch01
layout: default
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
  .slidev-layout:not(.new-section) {
    background: #ffffff !important;
  }
---

<div class="flex flex-col justify-center items-center h-full" style="background: #ffffff;">
  <p style="color: #5eada0; font-size: 1rem; font-weight: 600; letter-spacing: 0.2em; text-transform: uppercase; margin-bottom: 1.2rem;">
    Spring Boot Backend Masterclass
  </p>
  <h1 style="color: #1a5c5c; font-size: 3.8rem; font-weight: 900; line-height: 1.15; margin-bottom: 1.5rem;">
    Spring Boot 介紹
  </h1>
  <div style="height: 4px; width: 320px; background: linear-gradient(90deg, #5eada0, #a7d9d0); border-radius: 2px; margin-bottom: 1.5rem;"></div>
  <p style="color: #4a7c7c; font-size: 1.15rem; font-style: italic;">
    「踏入 Java 後端開發的第一步」
  </p>
  <Link to="home" style="color: #9dc4c4; font-size: 0.85rem; margin-top: 2rem; text-decoration: none; letter-spacing: 0.05em;">← 返回目錄</Link>
</div>

<!--
大家好，歡迎來到 Spring Boot Backend Masterclass 的第一章！

在正式開始之前，我想先問大家一個問題：你有沒有想過，我們每天用的電商網站、社群媒體，它們的後端是怎麼運作的？

今天，我們就從最基礎開始，認識讓 Java 後端工程師又愛又離不開的框架 — Spring Boot。

學完今天的內容，大家會清楚知道「Spring Boot 是什麼」、「它解決了什麼問題」，以及「為什麼值得花時間學習它」。
-->

---
layout: default
---

# Outline

- **Spring Boot 簡介** — 框架的概念、Spring Boot 從哪裡來
- **什麼是 Spring Boot？** — 定義、名稱由來、Spring 與 Spring Boot 的關係
- **Spring Boot 的優勢** — 兩大核心優勢詳解
- **章節總結** — 學完這章，你能說出什麼

<!--
這一章的架構非常清楚。

我們先從「框架」的概念說起，讓大家有個心理準備，理解為什麼我們需要 Spring Boot。

接著正式介紹 Spring Boot 是什麼、和傳統 Spring 框架有什麼關係。

然後深入說明它的兩個核心優勢 — 這是面試常考的題目，大家一定要記住。

最後用一個小總結收尾，讓大家帶著清晰的概念離開今天的課程。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第一部分
# Spring Boot 簡介

<!--
進入第一部分，我們先聊聊「框架」這個概念。

有些同學可能聽過「框架」這個詞很多次，但說不太清楚它到底是什麼。

沒關係，我用一個很生活化的比喻來說明。
-->

---

# 什麼是框架？

框架是「加速工程師開發效率」的工具包。

| 情境 | 沒有框架 | 有了框架 |
| --- | --- | --- |
| 蓋後端系統 | 用螺絲起子，一根一根鎖 | 直接用電鑽，快速組裝 |
| 開發速度 | 慢、繁瑣、容易出錯 | 快、簡潔、有規範 |
| 重複工作 | 每個專案都要從零開始 | 套用現成的最佳實踐 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>一句話定義：</b> 框架就是把「常見的後端開發需求」預先打包好，讓我們不必重複造輪子。
</div>

<!--
想像一下，如果你要蓋一棟房子。

沒有框架的時候，你要自己去生產每一根釘子、每一塊磚頭，然後一根一根地用螺絲起子把它們組合起來。光是「準備材料」就已經累壞了。

但有了框架之後，就像直接走進一家預製屋的工廠，材料都幫你備齊了，你只需要專注在「組裝」和「設計你的需求」上面。

框架存在的根本目的，就是讓工程師可以把時間花在真正有價值的事情上，而不是每次都從零開始。
-->

---

# Java 後端的主流選擇

在 Java 後端的世界裡，Spring Boot 是目前最受歡迎的框架。

| 框架 | 定位 | 市場地位 |
| --- | --- | --- |
| **Spring Boot** | 全功能後端框架 | Java 後端業界首選 |
| Spring MVC | Web 層框架（Spring Boot 已內建） | Spring Boot 的基礎之一 |
| Quarkus | 雲原生框架 | 輕量但相對小眾 |
| Micronaut | 微服務框架 | 輕量但相對小眾 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>業界現況：</b> Java 後端職缺中幾乎都會寫「需熟悉 Spring Boot」。有句話說：「不會 Spring，不談就業。」
</div>

<!--
為什麼我們要學 Spring Boot，而不是其他框架？

其實答案很簡單：因為業界在用它。

大家找工作的時候，看 Java 後端的職缺，十間公司有九間都會寫上「需熟悉 Spring Boot」。

這不是說其他框架不好，而是 Spring Boot 已經在業界建立了非常穩固的生態系。你學一個工具，要先確保它有市場需求，而 Spring Boot 絕對是有的。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第二部分
# 什麼是 Spring Boot？

<!--
好，現在我們知道框架是什麼，也知道 Spring Boot 很重要。

接下來，我們來正式認識 Spring Boot — 它是怎麼來的？它的名字有什麼含義？和傳統的 Spring 框架有什麼不同？
-->

---

# 什麼是 Spring Boot？

「Spring Boot 是建立在 Spring Framework 之上的框架，目的是讓 Spring 應用程式的開發更快、更簡單。」

| 組成 | 含義 |
| --- | --- |
| **Spring** | Java 最核心的後端框架，提供 IoC、AOP 等基礎能力 |
| **Boot**（開機） | 按下開機鍵就能用，代表「開箱即用」的精神 |
| **Spring Boot** | 把 Spring 的複雜設定自動化，讓你專注在業務邏輯 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>關鍵理解：</b> Spring Boot 並不是要「取代」Spring，而是讓 Spring 的使用門檻大幅降低。
</div>

<!--
Spring Boot 的名字拆開來看，其實很直觀。

「Spring」是核心：它是 Java 後端最重要的基礎框架，提供了很多強大的能力，例如 IoC（控制反轉）和 AOP（切面導向程式設計）。我們後面的章節都會詳細介紹這些。

「Boot」的意思是開機。就像你按下電腦的電源鍵，電腦就自動幫你啟動所有需要的程式 — Spring Boot 也是這樣，幫你自動完成大量繁瑣的設定。

所以 Spring Boot = Spring 的核心能力 + 自動化設定 + 開箱即用。
-->

---

# Spring 與 Spring Boot 的關係

用蓋房子來比喻這兩者的差異：

| 比喻 | 技術對應 | 說明 |
| --- | --- | --- |
| 磚頭、水泥、鋼筋 | Spring Framework | 最基礎的建材，強大但需要自己組裝 |
| 預製屋套件 | Spring Boot | 材料預先組好，直接按需求客製化 |
| 一鍵生成的樣品屋 | Spring Initializr | 線上工具，一鍵生成專案骨架 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>實際意義：</b> 傳統 Spring 需要撰寫大量 XML 設定檔；Spring Boot 幾乎不需要 XML，改用「約定優於配置」的方式自動完成。
</div>

<!--
我們用蓋房子來比喻 Spring 和 Spring Boot 的關係。

傳統的 Spring Framework 就像你拿到了所有原始建材 — 磚頭、水泥、鋼筋全都有。功能非常強大，但你得自己去學怎麼組裝，而且要寫很多 XML 設定檔，非常繁瑣。

Spring Boot 則像是預製屋套件。廠商已經把常見的組合方式都設計好了，你只需要告訴它「我要幾房幾廳」，它就幫你搞定大部分的設定。

這就是為什麼很多工程師從傳統 Spring 轉向 Spring Boot 之後，都會說：「啊，原來開發可以這麼爽。」
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第三部分
# Spring Boot 的優勢

<!--
知道了 Spring Boot 是什麼，接下來我們來說它的兩個核心優勢。

這也是面試官很愛問的問題：「Spring Boot 的優勢是什麼？」大家可以在心裡先記一下，等下我們來一個個說明。
-->

---

# 優勢一：簡化 Spring 開發

傳統 Spring 需要大量 XML 設定，Spring Boot 讓這些設定「消失」。

| 比較面向 | 傳統 Spring | Spring Boot |
| --- | --- | --- |
| 設定方式 | 大量 XML 設定檔 | 幾乎零設定，自動完成 |
| Web 伺服器 | 手動部署到 Tomcat | 內建 Tomcat，直接執行 |
| 依賴管理 | 手動確認版本相容性 | Starter 自動管理版本 |
| 開發體驗 | 如手動焊接零件造車 | 如走進店裡直接開走新車 |

<!--
傳統 Spring 的痛點很明顯：你需要寫很多 XML 設定檔，而且版本相容性問題讓人頭疼，這個過程工程師通常稱為「版本地獄」。

Spring Boot 解決了這些問題：
- XML 設定幾乎不需要了，改用 Java Config 和自動設定
- 內建 Tomcat，你不需要再單獨安裝和設定 Web 伺服器
- Starter 依賴幫你管理版本，告別版本地獄

這種感覺就像：以前要自己手動焊接每個零件才能開車，現在直接走進汽車店，付個錢就開走新車。
-->

---

# 優勢一：範例

只需幾行程式碼，就能啟動一個完整的 Web 服務。

```java
@SpringBootApplication
public class DemoApplication {
    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
}
```

執行後，Spring Boot 自動啟動內建 Tomcat（port 8080），不需要任何額外設定。

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>@SpringBootApplication：</b> 標記程式啟動入口，同時啟動 Spring Boot 的自動配置機制。
</div>

<!--
看這段程式碼，大家可以感受到 Spring Boot 的「簡單」。

整個 main class 只有 3 行有效程式碼，但它背後做了非常多的事：自動掃描 Bean、啟動 Tomcat、載入所有設定...

`@SpringBootApplication` 是這個魔法的關鍵。加上這個 Annotation，Spring Boot 就知道「這裡是程式的起點」，並且啟動所有的自動配置機制。

執行這段程式之後，你就已經有一個可以接收 HTTP 請求的 Web 服務了。這在傳統 Spring 裡面，要花更多時間和設定才能達到。

⚠️ 注意：`@SpringBootApplication` 只能加在一個主要的 class 上面，不能重複使用。
-->

---

# 優勢二：快速整合主流框架

Spring Boot 採用「**約定優於配置**」（Convention over Configuration）的設計哲學。

| 特色 | 說明 |
| --- | --- |
| **Starter 依賴** | 一個依賴包含所有需要的函式庫，自動管理版本 |
| **自動配置** | Spring Boot 預先設定好常用的配置，開箱即用 |
| **約定優於配置** | 遵循預設慣例，就不需要撰寫任何設定 |

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>白話說明：</b> Spring Boot 就像有經驗的資深工程師，把最佳實踐的設定都預設好了；你只在「需要客製化」的時候才去修改它。
</div>

<!--
第二個優勢是「快速整合主流框架」。

什麼是「約定優於配置」？

想像你去一家速食店。店員不會問你：「你要幾度的油炸溫度？薯條要炸幾分鐘？」這些都是「約定好的標準流程」，你不需要每次都重新指定。

Spring Boot 也是這樣。它預先約定好了很多「標準做法」，例如資料庫連線該怎麼設定、JSON 序列化該怎麼處理等等。

這讓整合其他工具（如資料庫、安全認證、快取）變得非常快速，通常只需要加上幾行依賴和簡單的設定就能完成。
-->

---

# 優勢二：Starter 依賴

只需加入一個 `spring-boot-starter-web`，就自動包含 Web 開發所需的所有函式庫。

```groovy
implementation 'org.springframework.boot:spring-boot-starter-web'
```

| Starter | 包含的功能 |
| --- | --- |
| `spring-boot-starter-web` | Spring MVC、內建 Tomcat、JSON 序列化 |
| `spring-boot-starter-data-jpa` | Spring Data JPA、Hibernate |
| `spring-boot-starter-security` | Spring Security 認證與授權 |

<!--
這就是 Starter 依賴的神奇之處。

在傳統 Spring 開發中，你需要一個個去找每個函式庫的 Gradle 依賴寫法，還要確認版本之間是否相容 — 這個過程叫做「版本地獄」，常常讓工程師抓狂。

Spring Boot 的 Starter 把這些都封裝好了。你只需要加入 `spring-boot-starter-web`，它就自動幫你引入 Spring MVC、內建 Tomcat、Jackson（JSON 序列化工具）等等，版本相容性也都幫你搞定。

在後面的章節，我們每次要用到新功能，都會先看需要加哪個 Starter，這是 Spring Boot 開發的固定步驟。
-->

---

# 搶先看：第一個 Spring Boot 程式

學完這門課，大家最終會能寫出這樣的 API：

```java
@RestController
public class MyController {

    @RequestMapping("/test")
    public String test() {
        System.out.println("Hi!");
        return "Hello World";
    }
}
```

瀏覽器開啟 `http://localhost:8080/test`，就會看到「Hello World」！

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
💡 <b>不用擔心：</b> 現在看不懂 @RestController 和 @RequestMapping 完全正常，後面的章節會一步一步詳細說明。
</div>

<!--
我想讓大家先看看「學完這門課能做什麼」。

這段程式碼只有幾行，但它已經是一個完整的 Web API — 瀏覽器打開對應的網址，就會收到伺服器回傳的 "Hello World"。

這個例子清楚展示了 Spring Boot 的魔力：用最少的程式碼，完成一個完整的後端功能。

`@RestController` 告訴 Spring Boot 這個 class 要處理 HTTP 請求；`@RequestMapping` 指定了這個方法對應哪個 URL 路徑。

現在如果看不懂，非常正常！這只是一個「先給大家看看成品」的環節。我們接下來的每一章都會詳細說明每個部分。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第四部分
# 章節總結

<!--
好，最後我們來整理一下今天學到了什麼。

每一章結束前，我們都會有一個這樣的總結頁，幫大家把重點整理清楚。
-->

---

# 總結

本章我們認識了 Spring Boot 的核心概念：

- **框架的目的** — 加速開發效率，讓工程師專注在業務邏輯，不必重複造輪子
- **什麼是 Spring Boot** — 建立在 Spring Framework 之上，「Boot」代表開箱即用的精神
- **Spring Boot 的地位** — Java 後端業界首選框架，幾乎是求職的必備技能
- **優勢一：簡化 Spring 開發** — 告別大量 XML 設定，內建 Tomcat，幾行程式碼就能啟動
- **優勢二：快速整合框架** — Starter 依賴 + 約定優於配置，整合其他工具超快速

<div class="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 text-gray-700 text-sm text-left">
🚀 <b>下一章：</b> 我們將安裝 MySQL、Git 與 GitHub Desktop，為正式開發做好準備！
</div>

<!--
今天的課程，我們完成了幾件重要的事。

第一，我們理解了「框架」的意義 — 它不是什麼神奇的東西，就是把常用的功能打包好，讓我們不必每次從零開始。

第二，我們認識了 Spring Boot — 它是 Spring 的升級版，用「約定優於配置」讓繁瑣的設定消失。

第三，我們看到了 Spring Boot 的兩個核心優勢：簡化開發和快速整合。

學完這章，大家應該能夠自信地說出「Spring Boot 是什麼、為什麼我們要用它」。這也是面試時一定會被問到的基礎題。

下一章，我們就要實際動手了 — 安裝環境、建立第一個專案，大家準備好了嗎？
-->

---
layout: end
---

# Q & A

有任何問題嗎？

<!--
現在開放 Q&A 時間。

大家對今天介紹的概念有沒有什麼疑問？無論是框架的概念、Spring Boot 的定義，還是那兩個優勢，都可以提問。

也歡迎分享你在學習過程中有沒有什麼「啊哈！原來如此」的感覺。
-->
