---
theme: penguin
class: text-center
highlighter: shiki
lineNumbers: true
drawings:
  persist: false
transition: slide-left
title: MySQL 資料庫課程
routeAlias: home
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

<style>
.chapter-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 1rem;
  width: 100%;
  max-width: 960px;
  margin-top: 1.2rem;
}
.chapter-card {
  display: block;
  background: #f0faf9;
  border: 2px solid #5eada0;
  border-radius: 12px;
  padding: 1.2rem 0.8rem;
  text-decoration: none !important;
  color: #1a5c5c !important;
  transition: all 0.2s ease;
}
.chapter-card:hover {
  background: #5eada0;
  color: white !important;
  transform: translateY(-3px);
  box-shadow: 0 6px 16px rgba(94, 173, 160, 0.35);
}
.chapter-card:hover .chapter-subtitle {
  color: rgba(255,255,255,0.85) !important;
}
.chapter-num {
  font-size: 1.6rem;
  font-weight: 900;
  margin-bottom: 0.3rem;
}
.chapter-subtitle {
  font-size: max(13px, 0.88rem);
  color: #4a7c7c;
  margin-top: 0.3rem;
}
</style>

<div class="flex flex-col items-center h-full" style="background: #ffffff; overflow-y: auto; padding: 1.5rem 0;">
  <p style="color: #5eada0; font-size: 1rem; font-weight: 600; letter-spacing: 0.2em; text-transform: uppercase; margin-bottom: 1rem;">MySQL 資料庫課程</p>
  <h1 style="color: #1a5c5c; font-size: 2.8rem; font-weight: 900; line-height: 1.2; margin-bottom: 0.5rem;">課程目錄</h1>
  <div style="height: 4px; width: 240px; background: linear-gradient(90deg, #5eada0, #a7d9d0); border-radius: 2px; margin-bottom: 0.5rem;"></div>
  <p style="color: #9dc4c4; font-size: 0.9rem; margin-bottom: 0;">點擊章節卡片開始學習</p>
  <div class="chapter-grid">
    <Link to="ch01" class="chapter-card">
      <div class="chapter-num">Ch 1</div>
      <div>資料庫設計原則</div>
      <div class="chapter-subtitle">PRIMARY KEY / FOREIGN KEY / 命名慣例</div>
    </Link>
    <Link to="ch02" class="chapter-card">
      <div class="chapter-num">Ch 2</div>
      <div>資料庫正規化</div>
      <div class="chapter-subtitle">1NF / 2NF / 3NF / Denormalization</div>
    </Link>
    <Link to="ch03" class="chapter-card">
      <div class="chapter-num">Ch 3</div>
      <div>資料表關聯設計</div>
      <div class="chapter-subtitle">一對一 / 一對多 / 多對多</div>
    </Link>
    <Link to="ch04" class="chapter-card">
      <div class="chapter-num">Ch 4</div>
      <div>DDL 資料定義語言</div>
      <div class="chapter-subtitle">CREATE / ALTER / DROP / TRUNCATE</div>
    </Link>
    <Link to="ch05" class="chapter-card">
      <div class="chapter-num">Ch 5</div>
      <div>DQL 資料查詢語言</div>
      <div class="chapter-subtitle">SELECT / WHERE / GROUP BY / HAVING</div>
    </Link>
    <Link to="ch06" class="chapter-card">
      <div class="chapter-num">Ch 6</div>
      <div>DML 資料操作語言</div>
      <div class="chapter-subtitle">INSERT / UPDATE / DELETE / Transaction</div>
    </Link>
    <Link to="ch07" class="chapter-card">
      <div class="chapter-num">Ch 7</div>
      <div>JOIN 合併查詢</div>
      <div class="chapter-subtitle">INNER / LEFT / RIGHT</div>
    </Link>
    <Link to="ch08" class="chapter-card">
      <div class="chapter-num">Ch 8</div>
      <div>Index 索引與執行計畫</div>
      <div class="chapter-subtitle">B-Tree / 複合索引 / EXPLAIN</div>
    </Link>
    <Link to="ch09" class="chapter-card">
      <div class="chapter-num">Ch 9</div>
      <div>VIEW 視圖</div>
      <div class="chapter-subtitle">CREATE VIEW / 管理 / 安全性</div>
    </Link>
    <Link to="ch10" class="chapter-card">
      <div class="chapter-num">Ch 10</div>
      <div>子查詢與進階查詢</div>
      <div class="chapter-subtitle">IN / LIKE / EXISTS / Correlated Subquery</div>
    </Link>
  </div>
</div>

---
src: ./ch01-db-design-principles.md
---
---
src: ./ch02-normalization.md
---
---
src: ./ch03-table-relations.md
---
---
src: ./ch04-ddl.md
---
---
src: ./ch05-dql.md
---
---
src: ./ch06-dml.md
---
---
src: ./ch07-join.md
---
---
src: ./ch08-index.md
---
---
src: ./ch09-view.md
---
---
src: ./ch10-subquery.md
---
