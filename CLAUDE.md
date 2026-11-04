# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Commands

```bash
pnpm dev              # Start dev server at localhost:3030
pnpm build            # Build to dist/ for deployment
pnpm export           # Export slides to PDF
```

Package manager is **pnpm** (not npm/yarn). The `.npmrc` sets `shamefully-hoist=true` required by Slidev.

## Architecture

This is a **Slidev** presentation project for MySQL curriculum. All slide files live at the root level.

### Entry Point
- `index.md` — Portal page (目錄頁) with chapter navigation cards. Imports all chapter decks via `src:`.

### Slide Decks
- `ch01-*.md`, `ch02-*.md`, … — Chapter slide files

### Vue Components
- `global-bottom.vue` — Footer rendered on every slide showing page X/Y

### Templates
- `_template/` — Blueprint for new chapters (slides.md, global-bottom.vue, package.json, style.css)

## Navigation

```yaml
# In slide frontmatter:
routeAlias: ch01
```

```html
<Link to="ch01">Go to Ch01</Link>
<Link to="home">← 返回目錄</Link>
```

## Adding a New Chapter

1. Copy `_template/slides.md` → `<chXX-name>.md` at root
2. Set `routeAlias: chXX` and `title:` in frontmatter
3. Add `src: ./<chXX-name>.md` block at end of `index.md`
4. Add `<Link to="chXX" class="chapter-card">` card to `index.md`'s `.chapter-grid`
5. Add script to `package.json`: `"chXX": "slidev <chXX-name>.md"`
6. Run `pnpm dev` — no additional installs needed

## Slidev Conventions

- Theme: `penguin` for all decks
- Per-slide layouts: `layout:` in slide front-matter (`section`, `two-cols`, `cover`, `default`)
- Progressive reveal: `v-click` / `v-clicks`
- Custom styles: inline in frontmatter `style:` block
- Tailwind utility classes work directly in slide markdown

## 貫穿專案：動態問卷系統

ch03–ch10 的練習題全部使用「動態問卷系統」的資料庫（`dynamic_survey`，六張表）。這是跨課程（MySQL / Spring Boot / Angular / Docker）的共用專案，**規格以 `SURVEY-SPEC.md` 為準**（各 repo 內容一致，修改時要同步）。

- `sql/schema.sql`：建表腳本（ch04 練習 1 的標準解答；含 `SET NAMES utf8mb4`）
- `sql/seed.sql`：範例資料，日期一律相對於 `CURDATE()`，所以「進行中／尚未開始／已結束」隨時執行都成立
- 練習題的 SQL 都已在 MySQL 8.x 實際執行驗證過；改題目時請先在 `schema.sql` + `seed.sql` 上跑過再寫進投影片
- 練習題只用該章之前教過的語法；沒教過的函式要在題目頁給提示
- 執行 SQL 檔時請用 `mysql --default-character-set=utf8mb4`，否則中文會被雙重編碼
