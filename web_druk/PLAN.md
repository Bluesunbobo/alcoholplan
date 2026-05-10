# 微醺志 (Druk) · 官网宣传规划

> **一款电影感饮酒追踪 App 的网站营销策略**
> 
> 灵感来源：Thomas Vinterberg 电影《Druk》(酒精计划 / Another Round)  
> 应用核心哲学：*"人类血液中天生缺少 0.05% 的酒精。"*

---

## 一、品牌定位与传播哲学

### 1.1 目标用户画像

| 维度 | 描述 |
|------|------|
| **核心受众** | 25–40岁，有品位的城市饮酒者，爱好文艺 / 电影 / 哲学 |
| **次要受众** | 健身与健康管理者，想要精确追踪身体状态的人 |
| **调性共鸣** | 既懂节制之美，又享受酒精带来的灵感松动 |
| **媒介习惯** | 微博、小红书、B站、豆瓣电影、公众号 |

### 1.2 传播核心主张

```
核心 Slogan（中文）：你喝的每一杯，都是一段故事。
Core Slogan（英文）：Every pour is a frame in your story.
副标语：用电影感，记录微醺时刻。
```

### 1.3 品牌调性定义

**视觉语言**：深夜酒馆 · 琥珀烛光 · 胶片颗粒 · 数据极简主义  
**情感底色**：克制 · 诗意 · 自知 · 哲学感  
**反对**：猎奇促酒、劝酒文化、酒精崇拜  
**支持**：自我认知、身体数据化、优雅节制  

---

## 二、网站整体架构（单页全屏滚动）

### 2.1 页面结构总览

```
Section 0: 片头开场（Cinematic Opener）
Section 1: 英雄区（Hero）
Section 2: 核心哲学（Philosophy）
Section 3: 功能展示 ①——实时 BAC 计算
Section 4: 功能展示 ②——全年热力图
Section 5: 功能展示 ③——电影级海报生成
Section 6: 功能展示 ④——历史场次时间线
Section 7: 下载区（Download CTA）
Section 8: 法律免责 + 页脚
```

### 2.2 各 Section 宣传重点

#### Section 0 · 片头开场
- 全黑背景，文字逐字显现
- 展示电影经典台词："人类血液中天生缺少 0.05% 的酒精。"
- 三语版本（中 / 英 / 丹麦语）依次淡入
- 底部标注：INSPIRED BY DRUK · 2020
- 用户点击任意处跳过，进入主页

#### Section 1 · Hero 区
- 主标题：微醺志 · DRUK
- 副标题：不只是饮酒记录，是一份关于灵魂松动的档案
- 背景：极深暗色，金色粒子动效（模拟酒精气泡上升）
- App 截图 Mockup 悬浮展示（3D 透视旋转动画）
- CTA 按钮：「立即下载」—— 分 iOS / Android 两个按钮

#### Section 2 · 哲学区
- 三块哲学卡片，模拟 App 内的 Philosophy Screen
- 内容：「0.05% 的真实」「克制的艺术」「在当下，去生活」
- 动画：随滚动逐一从下方淡入

#### Section 3 · BAC 实时计算
- 交互演示：网页内可模拟输入饮品，查看 BAC 曲线
- 或使用静态动画 GIF/视频展示 App 操作流程
- 标语：「用 Widmark 公式，精算你的清醒程度」

#### Section 4 · 全年热力图（重点宣传）
- 动态渲染一个全年 365 天的热力图（JavaScript Canvas/SVG）
- 颜色由浅至深代表 BAC 浓度，金琥珀色系
- 文案：「每一个亮起的格子，都是你生命中一个真实的夜晚」
- 副文：支持按年切换，自动统计年度酒精摄入量

#### Section 5 · 海报生成
- 展示 App 内的海报截图或动态样图
- 强调：一键生成电影感年度总结海报，可分享到社交媒体
- 标语：「把你的微醺史，变成一张电影海报」

#### Section 6 · 时间线
- 动画演示 Timeline 样式，显示场次记录卡片
- 展示酒类记录、时间戳、峰值 BAC 数据
- 标语：「每场饮酒，都有据可查」

#### Section 7 · 下载区
- iOS App Store 下载按钮（链接）
- Android APK 直接下载按钮
- QR Code 扫码下载
- 系统要求说明

#### Section 8 · 页脚
- 免责声明（基于 Widmark 公式，仅供参考）
- 隐私政策链接
- 版本号
- 金句收尾："In vino veritas, in aqua sanitas."

---

## 三、动画导演方案（电影感核心）

### 3.1 动画哲学

> 网站每一帧的过渡，都应该像电影蒙太奇——有节奏、有意图、有呼吸。

### 3.2 核心动画手法

| 技术 | 应用场景 | 效果目标 |
|------|----------|----------|
| **Scroll-driven 动画** | 各 Section 随滚动触发 | 沉浸式叙事节奏 |
| **粒子系统（Canvas）** | Hero 区背景、全屏过渡 | 气泡、尘埃、金粉质感 |
| **文字逐字显现** | 开场、Section 标题 | 打字机 / 电影字幕感 |
| **Parallax 视差** | 背景层与前景层 | 立体景深感 |
| **3D 透视旋转** | App 截图 Mockup | 高级展示质感 |
| **SVG 路径动画** | 热力图格子依次填充 | 一年记录的时间感 |
| **Glassmorphism 卡片** | Feature 卡片 | 与 App 风格统一 |
| **噪点纹理叠加** | 全页面 | 模拟胶片颗粒感 |
| **淡入淡出（ease curves）** | 所有文字 | 呼吸感、不仓促 |

### 3.3 色彩系统（与 App 完全对应）

```css
/* 来自 app_colors.dart */
--color-bg:             #161310;  /* surfaceDim */
--color-bg-card:        #1E1B18;  /* surfaceContainerLow */
--color-primary:        #FFB960;  /* primary / amberGold */
--color-amber:          #D9A54D;  /* amberGold */
--color-ivory:          #F7EDD9;  /* ivoryWarm */
--color-text:           #E9E1DC;  /* onSurface */
--color-text-muted:     #D6C3B1;  /* onSurfaceVariant */
--color-glass-border:   rgba(255,255,255,0.10);
--color-glass-bg:       rgba(255,255,255,0.05);
```

### 3.4 字体系统

```css
/* 与 App 完全对应 */
--font-serif-zh:  'Noto Serif SC', serif;         /* 中文正文、标题 */
--font-serif-en:  'Playfair Display', serif;       /* 英文大标题、斜体 */
--font-mono:      'Roboto Mono', monospace;        /* 数据、标签、TAG */
--font-serif-en2: 'Noto Serif', serif;             /* 英文引言 */
```

---

## 四、推广策略

### 4.1 社交媒体矩阵

| 平台 | 内容策略 | 频率 |
|------|----------|------|
| **小红书** | 美学截图 + 文艺短文案，热力图展示 | 2–3次/周 |
| **微博** | 话题讨论 + 金句摘录，#微醺时刻# | 每日 |
| **B站** | App 使用教程、功能展示视频 | 1次/周 |
| **豆瓣电影** | 与 Druk 电影讨论帖联动 | 不定期 |
| **微信公众号** | 深度文章：酒精哲学、饮酒文化 | 1次/周 |

### 4.2 内容营销方向

1. **电影联动**：结合 Thomas Vinterberg《Druk》电影，发布「电影与App」联名内容
2. **哲学内容**：每周发布一段关于酒精与人性的哲学短文（源于 App 内的 Philosophy Screen）
3. **热力图挑战**：鼓励用户分享自己的年度热力图截图，发起 #我的微醺年份# 话题
4. **海报生成器UGC**：引导用户生成并分享个人饮酒电影海报
5. **KOL 合作**：与文艺类 / 影评类 / 健康类博主合作推广

### 4.3 SEO 关键词策略

```
主关键词：饮酒记录 App、BAC 计算器、血液酒精浓度
长尾词：如何追踪饮酒量、微醺不醉的方法、Widmark 公式计算
品牌词：微醺志、Druk App、微醺记录
文化词：Druk 电影、0.05% 哲学、酒精计划
```

---

## 五、下载转化漏斗

```
广告/社交媒体 → 网站首页 → 功能展示 → 下载 CTA
                              ↓
                         哲学共鸣区（情感钩子）
                              ↓
                         热力图演示（功能钩子）
                              ↓
                     iOS / Android 下载按钮
```

### 5.1 iOS 下载
- 链接至 App Store 官方页面
- 按钮样式：Apple 官方黑色 "Download on the App Store" Badge

### 5.2 Android 下载
- 优先链接至 Google Play（如已上架）
- 备选：直接提供 APK 下载（hosted on server or GitHub Releases）
- 按钮样式：Google Play Badge 或自定义 APK 下载按钮

### 5.3 QR Code 策略
- 页面显示双二维码（iOS / Android 各一）
- 手机访问时自动检测系统，跳转对应商店

---

## 六、时间线与优先级

| 阶段 | 内容 | 目标完成时间 |
|------|------|-------------|
| **Phase 1** | 完成 `web_druk/index.html` 完整静态网站 | 优先完成 |
| **Phase 2** | 接入真实 iOS App Store 链接 + APK 托管 | App 上架后 |
| **Phase 3** | 添加热力图交互演示（JavaScript 动态版） | Phase 1 后 1 周 |
| **Phase 4** | 社交媒体内容批量生产 & 推送 | 持续 |
| **Phase 5** | SEO 优化 + Google Analytics 接入 | Phase 1 后 |

---

*文档版本：v1.0 · 2026-05-05*  
*由 Antigravity AI 生成，供微醺志项目团队参考*
