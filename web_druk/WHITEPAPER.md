# 微醺志 Web · 技术白皮书

版本：v1.0 | 2026-05-05 | 适用：任何 AI / 开发者可直接按此实现

---

## 1. 项目概述

**目标**：为 Flutter App「微醺志 (Druk)」构建一个纯静态、电影感宣传官网。  
**目录**：`/web_druk/`  
**交付物**：`index.html`（单文件，内嵌所有 CSS + JS）  
**部署方式**：任意静态托管（GitHub Pages / Vercel / Nginx）  
**技术栈**：原生 HTML5 + CSS3 + Vanilla JavaScript（无框架）

---

## 2. 文件结构

```
web_druk/
├── index.html          ← 主文件（全部内容）
├── PLAN.md             ← 营销策略（已存在）
├── WHITEPAPER.md       ← 本文件
└── assets/             ← 可选（App 截图、APK 文件）
    ├── screenshot_1.png
    ├── screenshot_2.png
    └── druk.apk
```

---

## 3. 页面分区规范

### Section 0 — 电影开场（`#cinematic-opener`）

**行为**：页面加载后全屏播放，约 8 秒，可点击跳过。

```
状态机：
  phase 0 (0–2s)   → 中文引言淡入
  phase 1 (2–4s)   → 英文引言淡入
  phase 2 (4–5.5s) → 丹麦语引言淡入
  phase 3 (5.5–7s) → 署名 "— Finn Skårderud · DRUK · 2020" 淡入
  phase 4 (7–8s)   → "点击进入" 提示淡入
  click 任意处      → 整体淡出，显示主页
```

**CSS 关键点**：
- 背景 `#050505`（比主背景更黑）
- `position: fixed; z-index: 9999;` 覆盖全屏
- 使用 `opacity` + `transition: opacity 1.5s ease` 控制淡入淡出

**JS 实现**：
```javascript
// 核心逻辑骨架
const opener = document.getElementById('cinematic-opener');
const phases = document.querySelectorAll('.opener-phase');
const delays = [0, 2000, 4000, 5500, 7000]; // 各阶段延迟 ms

delays.forEach((delay, i) => {
  setTimeout(() => {
    if (phases[i]) phases[i].style.opacity = 1;
  }, delay);
});

opener.addEventListener('click', () => {
  opener.style.opacity = 0;
  setTimeout(() => opener.remove(), 1200);
});
```

---

### Section 1 — Hero 区（`#hero`）

**布局**：全屏 `min-height: 100vh`，flex 垂直居中

**内容**：
1. 顶部 Logo 文字：`微醺志 · DRUK`（Playfair Display + Noto Serif SC 组合）
2. 副标题：`不只是饮酒记录，是一份关于灵魂松动的档案`
3. 英文副标：`Every pour is a frame in your story.`
4. 下载按钮组（见第 7 节）
5. 背景：Canvas 粒子动画

**粒子动画规范**：
```javascript
// 粒子系统参数
const PARTICLE_COUNT = 80;
const PARTICLE_COLOR = 'rgba(217, 165, 77, '; // amberGold，后跟 opacity
// 每粒子：随机 x, y 起点，向上漂移，透明度随高度递减
// 粒子大小：1–3px 圆形
// 速度：0.3–0.8 px/frame（缓慢上升）
// 到顶后重置到底部随机位置
```

---

### Section 2 — 哲学区（`#philosophy`）

**内容**：三张 Glassmorphism 卡片，随滚动依次淡入

| 卡片 | 英文标题 | 中文标题 |
|------|----------|----------|
| 1 | THE 0.05% TRUTH | 0.05% 的真实 |
| 2 | THE ART OF RESTRAINT | 克制的艺术 |
| 3 | BE HERE, NOW | 在当下，去生活 |

**卡片 CSS**：
```css
.glass-card {
  background: rgba(255,255,255,0.05);
  border: 1px solid rgba(255,255,255,0.10);
  border-radius: 20px;
  backdrop-filter: blur(12px);
  padding: 40px;
}
```

**Scroll 动画**：使用 `IntersectionObserver`，进入视口时 class `is-visible` → `opacity:0,translateY(40px)` 变为 `opacity:1,translateY(0)`

---

### Section 3 — BAC 计算展示（`#bac-demo`）

**内容**：静态 SVG 折线图模拟 BAC 曲线，加动画描边效果

**SVG 动画技巧**：
```css
.bac-line {
  stroke-dasharray: 1000;
  stroke-dashoffset: 1000;
  transition: stroke-dashoffset 2s ease-in-out;
}
.bac-line.animated {
  stroke-dashoffset: 0; /* 进入视口时触发 */
}
```

**图表样式**：
- 背景：`#1E1B18`
- 线条颜色：`#FFB960`（primary）
- 网格线：`rgba(255,255,255,0.05)`
- X轴：时间（0h–8h），Y轴：BAC（0–0.10%）

---

### Section 4 — 全年热力图（`#heatmap`）⭐ 重点

**这是网站最核心的功能展示区域。**

**布局**：
- 左侧：功能文案
- 右侧：动态热力图演示

**热力图渲染规范**：
```javascript
// 参数
const COLS = 26;        // 26列
const ROWS = 14;        // 14行（26×14=364，接近365）
const CELL_SIZE = 12;   // px
const CELL_GAP = 3;     // px

// 颜色映射（与 App 完全一致）
function getColor(bac) {
  if (bac <= 0)   return 'rgba(255,255,255,0.04)';
  if (bac < 0.02) return 'rgba(217,165,77,0.20)';
  if (bac < 0.04) return 'rgba(217,165,77,0.40)';
  if (bac < 0.06) return 'rgba(217,165,77,0.60)';
  if (bac < 0.08) return 'rgba(217,165,77,0.80)';
  return 'rgba(217,165,77,1.00)';
}

// 演示数据：随机生成模拟一年的饮酒数据
// 约 60% 的格子为 0（未饮酒），40% 随机分配 BAC 值

// 动画：格子依次点亮
// 每格间隔 8ms，总计约 2.9 秒完成全年回放
function animateHeatmap(cells) {
  cells.forEach((cell, i) => {
    setTimeout(() => {
      cell.style.backgroundColor = getColor(cell.dataset.bac);
      cell.style.transition = 'background-color 0.3s ease';
    }, i * 8);
  });
}
```

**文案**：
- 主标：`全年微醺档案 / VINTAGE FREQUENCY`
- 副标：`每一个亮起的格子，都是你生命中一个真实的夜晚`
- 数据展示：`365 天 · XX 场次 · XXg 纯酒精`

---

### Section 5 — 海报生成（`#poster`）

**内容**：展示 App 海报截图的 Mockup 展示

**Mockup 样式**：
```css
.phone-mockup {
  width: 280px;
  border-radius: 40px;
  border: 8px solid rgba(255,255,255,0.08);
  box-shadow: 
    0 40px 80px rgba(0,0,0,0.6),
    0 0 0 1px rgba(255,255,255,0.05),
    inset 0 0 40px rgba(255,185,96,0.05); /* amber glow */
  transform: perspective(1000px) rotateY(-12deg) rotateX(4deg);
  transition: transform 0.6s ease;
}
.phone-mockup:hover {
  transform: perspective(1000px) rotateY(0deg) rotateX(0deg);
}
```

---

### Section 6 — 时间线（`#timeline`）

**内容**：3 张示例 Session 卡片，模拟 App 历史页样式

**卡片信息结构**：
```
[日期时间] [酒类 emoji]
酒名 + 容量 + ABV
峰值 BAC: 0.032%
场合 / 地点
```

**左侧竖线**：
```css
.timeline-line {
  position: absolute;
  left: 20px; top: 0; bottom: 0;
  width: 1px;
  background: linear-gradient(
    to bottom,
    transparent, rgba(255,185,96,0.3), transparent
  );
}
```

---

### Section 7 — 下载区（`#download`）

**内容**：

```html
<!-- iOS 下载 -->
<a href="https://apps.apple.com/YOUR_LINK" class="download-btn ios-btn">
  <svg><!-- Apple Logo SVG --></svg>
  <div>
    <span class="label">Download on the</span>
    <span class="store">App Store</span>
  </div>
</a>

<!-- Android 下载 -->
<a href="./assets/druk.apk" class="download-btn android-btn" download>
  <svg><!-- Android Logo SVG --></svg>
  <div>
    <span class="label">Download for</span>
    <span class="store">Android (APK)</span>
  </div>
</a>
```

**系统检测（自动高亮对应按钮）**：
```javascript
const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent);
const isAndroid = /Android/.test(navigator.userAgent);
if (isIOS) document.querySelector('.ios-btn').classList.add('highlighted');
if (isAndroid) document.querySelector('.android-btn').classList.add('highlighted');
```

**按钮样式**：
```css
.download-btn {
  display: flex; align-items: center; gap: 16px;
  padding: 16px 32px;
  background: rgba(255,255,255,0.05);
  border: 1px solid rgba(255,255,255,0.15);
  border-radius: 16px;
  color: #F7EDD9;
  text-decoration: none;
  transition: all 0.3s ease;
}
.download-btn:hover, .download-btn.highlighted {
  background: rgba(255,185,96,0.15);
  border-color: rgba(255,185,96,0.5);
  box-shadow: 0 0 30px rgba(255,185,96,0.1);
}
```

---

### Section 8 — 页脚（`#footer`）

**内容**：
1. 免责声明（中英双语）
2. 版本号：`v1.0.0`
3. 链接：隐私政策 / 哲学页
4. 收尾金句：`"In vino veritas, in aqua sanitas."`
5. 版权：`© 2026 微醺志 · Druk App`

---

## 4. 全局 CSS 规范

```css
/* CSS 变量（必须在 :root 中定义） */
:root {
  --bg:            #161310;
  --bg-card:       #1E1B18;
  --bg-card-high:  #231F1C;
  --primary:       #FFB960;
  --amber:         #D9A54D;
  --ivory:         #F7EDD9;
  --text:          #E9E1DC;
  --text-muted:    #D6C3B1;
  --glass-bg:      rgba(255,255,255,0.05);
  --glass-border:  rgba(255,255,255,0.10);
  
  --font-zh:    'Noto Serif SC', serif;
  --font-en:    'Playfair Display', serif;
  --font-mono:  'Roboto Mono', monospace;
}

/* 全局基础 */
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
html { scroll-behavior: smooth; }
body {
  background: var(--bg);
  color: var(--text);
  font-family: var(--font-zh);
  overflow-x: hidden;
}

/* 噪点纹理叠加（模拟胶片颗粒感） */
body::before {
  content: '';
  position: fixed; inset: 0; z-index: 0; pointer-events: none;
  background-image: url("data:image/svg+xml,..."); /* SVG 噪点 */
  opacity: 0.03;
}

/* Google Fonts 引入（在 <head> 中） */
/* @import url('https://fonts.googleapis.com/css2?family=Noto+Serif+SC:wght@400;500;700&family=Playfair+Display:ital,wght@0,700;1,400;1,700&family=Roboto+Mono:wght@400;700;900&display=swap'); */

/* Scroll 动画基础类 */
.fade-up {
  opacity: 0;
  transform: translateY(40px);
  transition: opacity 0.8s ease, transform 0.8s ease;
}
.fade-up.is-visible {
  opacity: 1;
  transform: translateY(0);
}
```

---

## 5. JavaScript 模块清单

```
js/
├── opener.js       — 电影开场逻辑（Phase 状态机 + 点击跳过）
├── particles.js    — Canvas 粒子系统（Hero 背景）
├── heatmap.js      — 热力图渲染 + 动画
├── scroll.js       — IntersectionObserver（所有 fade-up 动画）
├── bac-chart.js    — SVG BAC 曲线描边动画
└── download.js     — 系统检测 + 按钮高亮
```

**如果单文件实现**，所有 JS 合并到 `<script>` 底部，按模块用注释分隔。

---

## 6. 响应式断点

```css
/* 移动端优先 */
/* ≤ 768px  : 单列布局，字体缩小 */
/* ≥ 769px  : 双列布局（文案 + Mockup） */
/* ≥ 1200px : 宽屏，内容最大宽度 1100px，居中 */

.container {
  width: 100%;
  max-width: 1100px;
  margin: 0 auto;
  padding: 0 24px;
}

@media (max-width: 768px) {
  .feature-layout { flex-direction: column; }
  .phone-mockup { transform: none; width: 220px; }
  .download-buttons { flex-direction: column; }
}
```

---

## 7. SEO & Meta 标签模板

```html
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>微醺志 · Druk — 用电影感，记录微醺时刻</title>
  <meta name="description" content="微醺志是一款电影感饮酒追踪 App，灵感来自电影《Druk》。实时 BAC 计算、全年热力图、电影级海报生成。">
  <meta name="keywords" content="饮酒记录,BAC计算,微醺,Druk,血液酒精浓度,饮酒追踪">
  
  <!-- Open Graph（社交分享） -->
  <meta property="og:title" content="微醺志 · Druk">
  <meta property="og:description" content="每一杯，都是一段故事。">
  <meta property="og:image" content="./assets/og-cover.jpg">
  <meta property="og:type" content="website">
  
  <!-- 主题色 -->
  <meta name="theme-color" content="#161310">
</head>
```

---

## 8. 任务清单（供 AI 执行）

```
[ ] 创建 web_druk/index.html
[ ] 实现 Section 0: 电影开场（状态机 + 淡入淡出）
[ ] 实现 Section 1: Hero 区（粒子背景 + 标题 + 下载按钮）
[ ] 实现 Section 2: 哲学区（3 张 GlassMorphism 卡片 + Scroll 动画）
[ ] 实现 Section 3: BAC 图表（SVG 描边动画）
[ ] 实现 Section 4: 全年热力图（26×14 网格 + 逐格点亮动画）⭐
[ ] 实现 Section 5: 海报展示（3D Phone Mockup）
[ ] 实现 Section 6: 时间线（3 张 Session 卡片 + 左侧竖线）
[ ] 实现 Section 7: 下载区（iOS / Android 按钮 + 系统检测）
[ ] 实现 Section 8: 页脚（免责声明 + 金句）
[ ] 全局：噪点纹理叠加
[ ] 全局：IntersectionObserver 滚动动画
[ ] 全局：响应式适配（移动端）
[ ] 验证：在 Chrome / Safari 打开，检查动画流畅度
```

---

## 9. 预期效果描述

| 区域 | 预期效果 |
|------|---------|
| 开场 | 纯黑背景，文字如电影字幕般缓缓浮现，3 种语言，肃穆而诗意 |
| Hero | 金色粒子在深暗背景中缓缓上升，App 名以烫金色大字呈现 |
| 哲学 | 三张毛玻璃卡片随滚动逐一浮现，文字克制、深沉 |
| 热力图 | 365 个格子从左至右依次点亮，金琥珀色渐变，震撼的数据美学 |
| 下载 | 两个按钮清晰区分 iOS / Android，当前设备对应按钮自动高亮 |
| 整体 | 如同观看一部短片，有起承转合，有情绪节奏 |

---

*文档版本：v1.0 · 2026-05-05*
