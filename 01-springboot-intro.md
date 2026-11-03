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
大家好，歡迎來到 Spring Boot Backend Masterclass 的第一章。

我們每天用的電商網站，背後都有後端系統在運作。在 Java 的世界裡，打造後端最常用的工具就是 Spring Boot。

這一章我們先從最基礎開始。學完之後，大家會清楚知道 Spring Boot 是什麼、它解決了什麼問題，以及為什麼值得花時間學它。
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
這一章的路線是這樣的。先從「框架」這個概念說起，理解為什麼我們需要它。接著正式認識 Spring Boot，以及它和傳統 Spring 的關係。然後說明它的兩個核心優勢，這也是面試常問的題目。最後用一個總結，把重點整理起來。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第一部分
# Spring Boot 簡介

<!--
我們先來聊聊「框架」。這個詞大家可能常聽到，但不一定說得清楚，我們用生活的例子來看。
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
「框架就是把常見的後端開發需求預先打包好，讓我們不必重複造輪子。」

想像我們要組裝一套家具。沒有工具的時候，只能拿螺絲起子一根一根鎖，又慢又容易出錯。有了電鑽，同樣的工作很快就完成了。

表格就是這個對照。沒有框架，每個專案都得從零開始，處理一樣的基礎工作。有了框架，就能直接套用前人整理好的最佳做法，開發又快又有規範。

所以框架存在的目的，就是讓工程師把時間花在真正有價值的地方，也就是我們自己的業務需求，而不是一次又一次重做基礎建設。
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
那麼 Java 後端有那麼多框架，為什麼要學 Spring Boot？

表格列出了幾個常見的選擇。Spring MVC 其實已經內建在 Spring Boot 裡了。Quarkus 和 Micronaut 都很輕量，但相對小眾。Spring Boot 則是業界首選的全功能後端框架。

答案其實很實際，因為業界在用它。打開 Java 後端的職缺，大部分都會寫上需要熟悉 Spring Boot。

這不代表其他框架不好，而是 Spring Boot 已經建立了非常穩固的生態系。學一個工具之前先確認它有市場需求，Spring Boot 在這點上非常可靠。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第二部分
# 什麼是 Spring Boot？

<!--
知道了框架的意義，接下來正式認識 Spring Boot：它從哪裡來，名字又代表什麼。
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
「Spring Boot 是建立在 Spring Framework 之上的框架，目的是讓 Spring 應用程式的開發更快、更簡單。」

我們把名字拆開來看。Spring 是 Java 後端最核心的基礎框架，提供 IoC 和 AOP 這些強大的能力，後面的章節都會詳細介紹。Boot 是開機的意思，就像按下電腦的電源鍵，系統就自動準備好一切，代表「開箱即用」的精神。

合起來，Spring Boot 就是把 Spring 繁瑣的設定自動化，讓我們專注在業務邏輯。

要特別注意，Spring Boot 不是要取代 Spring，而是讓 Spring 的使用門檻大幅降低。
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
我們用蓋房子來比喻這三者的關係。

Spring Framework 像是磚頭、水泥和鋼筋，什麼都有，功能很強大，但得自己學怎麼組裝。傳統的 Spring 還需要寫大量的 XML 設定檔，非常繁瑣。

Spring Boot 像預製屋套件，常見的組合方式都已經設計好了，只要告訴它需要什麼，大部分的設定它就幫我們處理好。

表格最後一列的 Spring Initializr 是一個線上工具，像是一鍵生成的樣品屋，選好需要的功能，就能直接產生專案的骨架。

畫面下方提到的「約定優於配置」，就是 Spring Boot 能省掉這些設定的關鍵，我們等一下會說明。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第三部分
# Spring Boot 的優勢

<!--
認識了 Spring Boot 之後，我們來看它的兩個核心優勢，這也是面試官很愛問的題目。
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
第一個優勢，是簡化 Spring 的開發。表格比較了四個面向。

設定方式上，傳統 Spring 要寫大量 XML，Spring Boot 幾乎都能自動完成。Web 伺服器方面，以前要另外安裝 Tomcat，再把程式部署上去，Spring Boot 已經內建，直接執行就好。依賴管理上，以前要自己確認每個函式庫的版本是否相容，Spring Boot 用 Starter 幫我們管好版本。

最後一列的比喻很貼切。以前像是要自己焊接每個零件才能造出一台車，現在就像走進車行，直接把新車開走。
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
我們用程式碼來感受一下有多簡單。這段程式的目的，是啟動一個完整的 Web 服務。

整個 class 只有幾行。關鍵是最上面的 `@SpringBootApplication`，它告訴 Spring Boot 這裡是程式的起點，同時啟動所有的自動配置機制。main 方法裡的 `SpringApplication.run`，則是真正把應用程式啟動起來。

執行後，Spring Boot 會自動啟動內建的 Tomcat，在 8080 這個 port 等待請求。不需要任何額外設定，我們就已經有一個能接收 HTTP 請求的 Web 服務了。

在傳統 Spring 裡，要達到同樣的效果，得花更多時間寫設定。

另外要注意，`@SpringBootApplication` 一個專案只放在一個主要的 class 上。
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
第二個優勢，是能快速整合主流框架，背後的設計哲學叫做「約定優於配置」。

想像我們去速食店點薯條，店員不會問要用幾度的油、炸幾分鐘，這些都是約定好的標準流程，我們不用每次指定。

Spring Boot 也一樣。表格列出了三個特色。Starter 依賴把需要的函式庫打包好。自動配置預先設定好常用的設定。只要遵循這些慣例，就不需要另外寫設定。

就像畫面下方說的，Spring Boot 像一位資深工程師，把最佳做法都預設好了，我們只有在需要客製化的時候才去修改。所以要整合資料庫、安全認證這些工具，通常只要加幾行依賴就能完成。
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
這頁來看 Starter 依賴實際怎麼用。

在傳統開發中，我們得一個一個找每個函式庫的依賴寫法，還要確認版本彼此相容，這個過程常被稱為「版本地獄」。

有了 Starter，只要加上程式碼裡這一行 `spring-boot-starter-web`，就會自動引入 Spring MVC、內建的 Tomcat，以及處理 JSON 的工具，版本相容也都處理好了。

表格還列了另外兩個常用的 Starter。`data-jpa` 用來操作資料庫，`security` 處理認證和授權。

之後的章節，每次要用新功能，我們都會先看需要加哪一個 Starter，這是 Spring Boot 開發的固定步驟。
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
最後，我們先看看學完這門課能做出什麼。

這段程式碼只有幾行，卻已經是一個完整的 Web API。`@RestController` 告訴 Spring Boot，這個 class 要處理 HTTP 請求。`@RequestMapping` 則指定這個方法對應的網址路徑，也就是斜線 test。

執行後，用瀏覽器打開 `http://localhost:8080/test`，畫面上就會顯示 Hello World。

這就是 Spring Boot 的魅力，用很少的程式碼，完成一個完整的後端功能。

現在看不懂這兩個註解是完全正常的，這裡只是先讓大家看看成品，後面的章節會一步一步詳細說明。
-->

---
layout: section
class: flex flex-col justify-center items-center text-center
---

# 第四部分
# 章節總結

<!--
最後我們來整理一下，這一章學到了哪些重點。
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
我們來回顧這一章。框架的目的是加速開發，讓我們不必重複造輪子。Spring Boot 建立在 Spring Framework 之上，Boot 代表開箱即用的精神，也是 Java 後端業界的首選。

它有兩個核心優勢，一是簡化 Spring 開發，二是靠 Starter 和約定優於配置快速整合其他框架。

下一章，我們要安裝 MySQL、Git 和 GitHub Desktop，為正式開發做好準備。
-->

---
layout: end
---

# Q & A

有任何問題嗎？

<!--
今天我們從框架的概念出發，認識了 Spring Boot 的由來，以及它簡化開發、快速整合這兩個核心優勢。這些是之後所有章節的基礎，也是面試時常被問到的題目。

下一章，我們就要開始動手準備開發環境了。我們下一章見。

【講師】開放提問，可以從框架的概念、Spring 和 Spring Boot 的關係，或兩個優勢引導大家發問。
-->
