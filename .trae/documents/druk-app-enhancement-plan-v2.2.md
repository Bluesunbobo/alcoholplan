# Druk App 功能完善计划：曲线、历史、人物设定模块

> 基于 stitch_tavern_bac_calculator_ui 设计稿的 UI/UX 升级方案
> 计划日期：2026-04-13
> 版本：v2.2 Enhancement Plan

---

## 一、总体目标

根据 `stitch_tavern_bac_calculator_ui` 文件夹中的高保真 UI 设计稿，对以下三个核心模块进行功能完善和视觉升级：

1. **曲线模块** (CurveView) - 清醒预测曲线
2. **历史模块** (HistoryView) - 饮酒记录与热图
3. **人物设定模块** (SettingsView) - 人格档案与设置

---

## 二、设计系统规范（来自 DESIGN.md）

### 2.1 视觉风格定位
- **创意北极星**：「The Sommelier's Ledger」（侍酒师的账本）
- **氛围**：高端、电影感、反思性、神秘
- **隐喻**：皮革账本放在红木吧台上，在爱迪生灯泡的光晕下

### 2.2 核心设计原则
1. **「无界线」规则**：禁止使用 1px 实线边框做分区，边界仅通过背景色变化或微妙色调过渡定义
2. **表面层级嵌套**：
   - Base: `#161310` (surface)
   - 分区: `#1e1b18` (surface-container-low)
   - 交互卡片: `#231f1c` (surface-container)
   - 浮动元素: `#383431` (surface-container-highest)
3. **玻璃拟态**：所有主要数据卡片使用 `surface-variant` 40% 不透明度 + `20px` backdrop-blur
4. **排版对话**：
   - 标题/标题：Newsreader/Serif（编辑性声音）
   - 数据/指标：Space Grotesk/Monospace（功能性精确）
   - 正文：Manrope/Sans（清晰易读）

### 2.3 色彩系统
- 主背景：`#161310`（近黑深棕）
- 强调色·金：`#ffb960` → `#c8862a`（琥珀金渐变）
- 警告色：`#f16771`（深酒红）
- 主文字：`#f0e6d3`（奶油白）
- 次文字：`#d6c3b1`（暖灰）

---

## 三、模块一：曲线页面升级（CurveView）

### 3.1 当前实现 vs 设计稿差异

| 元素 | 当前实现 | 设计稿要求 |
|------|---------|-----------|
| 页面标题 | "The Curve / 预演曲线" | "清醒曲线 / The Sobriety Curve" |
| 副标题 | "Sobriety Prediction" | "实时血液酒精估算与代谢恢复预测 / Real-time blood alcohol estimation and metabolic recovery projection." |
| 状态卡片 | 无独立状态卡 | 玻璃拟态卡片显示「预计 BAC」+ 大数字 + 状态标签 |
| 曲线图 | 基础 Swift Charts | 更精美的曲线，带渐变填充、参考线标注 |
| 时间信息 | 仅底部显示 | X轴显示时间范围 + NOW 标记更明显 |
| 清醒时间 | 底部小字 | 独立大字区块 "4-6 小时后 / Hours Later" |
| 法定安全距离 | 无 | 新增 "距离法定安全 / Distance to Legal Safety: 2h 20m" |
| 统计卡片 | 无 | 两列 Bento 卡片：总摄入 / 峰值强度 |

### 3.2 实施步骤

#### Step 1: 重构页面布局结构
```
ScrollView
├── Header Section（标题区）
│   ├── H1: "清醒曲线 / The Sobriety Curve" (Newsreader Italic, 32pt)
│   └── Subtitle: "实时血液酒精酒精估算..." (18pt, opacity 0.6)
│
├── Status Card（状态卡片）[Glass Card]
│   ├── Label: "预计 BAC / ESTIMATED BAC"
│   ├── Big Number: "0.054%" (SF Mono, 56pt, Primary)
│   └── Status Tag: "代谢中 / Metabolizing"
│
├── Chart Card（曲线图表）[Glass Card]
│   ├── Chart Header: "BAC TIMELINE"
│   ├── Swift Charts Canvas
│   │   ├── LineMark (实线 + 渐变填充)
│   │   ├── RuleMark: NOW (竖向虚线)
│   │   ├── RuleMark: 0.05% Golden Point (金色虚线)
│   │   ├── RuleMark: DUI Line (橙色)
│   │   └── RuleMark: DWI Line (红色)
│   └── X-Axis Time Range Labels
│
├── Sobering Time Section（清醒时间）
│   ├── Label: "预计清醒时间 / ESTIMATED SOBRIETY IN"
│   └── Big Text: "4-6 小时后 / Hours Later"
│
├── Legal Safety Section（法定安全距离）
│   ├── Icon + Label: "距离法定安全 / Distance to Legal Safety"
│   └── Time: "2h 20m"
│
└── Stats Bento Grid（统计网格）
    ├── Card 1: 总摄入 / TOTAL INTAKE → "3 Standard"
    └── Card 2: 峰值强度 / PEAK INTENSITY → "11:45 PM"
```

#### Step 2: 增强曲线图视觉效果
- 添加曲线下方的渐变填充（Primary 色 20% 不透明度）
- 优化参考线样式（虚线 + 标注文字）
- NOW 标记使用动画脉冲效果
- 曲线绘制时添加「生长」动画（从左到右）

#### Step 3: 实现动态数据绑定
- 从 `AlcoholBrain` 获取当前 BAC 显示在状态卡片
- 调用 `calculateMetabolicEnd()` 显示清醒时间
- 计算距离法定安全线的剩余时间
- 显示 sessionUnits 和峰值时间

#### Step 4: 添加微交互
- 状态卡片数字更新时的计数器滚动动效
- 曲线图的触摸交互（显示具体时间点的 BAC 值）
- 下拉刷新重新计算曲线

---

## 四、模块二：历史页面升级（HistoryView）

### 4.1 当前实现 vs 设计稿差异

| 元素 | 当前实现 | 设计稿要求 |
|------|---------|-----------|
| 页面标题 | "Your Nights / 你的那些夜晚" | 保持一致 ✅ |
| 热力图 | 静态 mock 数据 | 应该基于真实数据渲染色块深浅 |
| 热力图尺寸 | 26列 × 7行（182格） | 保持一致 ✅ |
| 时间线样式 | 基础圆点 + 线 | 渐变线 + 发光圆点 + 阴影 |
| 记录卡片 | 简单布局 | 更丰富的信息层次（日期格式、标签样式）|
| 台词引用 | 基础文本 | 包含作者署名（— F. Scott Fitzgerald）|
| 宿醉评分 | 固定 emoji | 根据实际评分值动态显示 |
| 删除交互 | 左滑删除 | 保持一致 ✅ |

### 4.2 实施步骤

#### Step 1: 升级热力图组件（HistoryHeatMapGrid）
```swift
// 新增功能：
1. 根据 sessions 数据计算每日饮酒量
2. 映射到 4 级颜色深度：
   - Level 0: bg-primary/5%（无饮酒或极轻）
   - Level 1: bg-primary/10%（轻微）
   - Level 2: bg-primary/40%（中等）
   - Level 3: bg-primary/70%（较重）
   - Level 4: bg-primary/100%（酣畅）
3. 动态生成当前年份的热力图（365天或 366天）
4. 添加月份标签（可选）
```

#### Step 2: 增强时间线视觉效果（HistoryTimelineView）
```swift
// 视觉升级：
1. 时间线改为渐变色：
   - from: primary/40%
   - via: primary/5%
   - to: transparent
2. 圆点添加发光效果：
   - shadow: [0_0_10px_rgba(255,185,96,0.5)]
   - 最新记录圆点为实心 primary 色
   - 历史记录圆点为 primary/40%
3. 卡片悬停/点击态：
   - hover: bg-surface-container transition-all duration-500
   - group 样式支持
```

#### Step 3: 丰富记录卡片内容（HistorySessionCard）
```swift
// 信息层次优化：
1. 日期格式：
   - 当前: date.formatted(.dateTime.month().day().year())
   - 优化: "OCT 24, 2023" (Monospace, uppercase, primary/60)
2. 场合标签：
   - 使用 Pill 样式：bg-primary/10 text-primary
   - font-label tracking-wider
3. 峰值 BAC：
   - 更大的字体 (text-2xl)
   - 添加 "PEAK BAC / 峰值 BAC" 小标签
4. 宿醉评分：
   - 动态读取 session.hangoverScore
   - 根据 0-5 分显示对应数量的 emoji
   - 未评分显示灰色占位符
5. 可选字段（如果 Core Data 有数据）：
   - 地点 location
   - 心情 moodEmoji
   - 备注 note
```

#### Step 4: 升级台词引用块
```swift
// 台词块增强：
struct CinematicQuoteView: View
    // 中文台词（font-headline italic, text-base, on-surface-variant/50）
    // 英文翻译（font-headline italic, text-sm, on-surface-variant/30）
    // 作者署名（font-label text-[8px] tracking-[0.2em], uppercase, opacity-30）
    // 格式: "— Author Name"
```

#### Step 5: 添加空状态设计
```swift
// 当 sessions.isEmpty 时：
VStack(spacing: 16) {
    Image(systemName: "book.closed")
        .font(.system(size: 48))
        .foregroundColor(.primary.opacity(0.3))
    Text("暂无回忆 / No nights recorded.")
        .font(.label)
        .foregroundColor(.onSurfaceVariant)
    Text("开始记录你的第一杯酒吧 / Start logging your first drink")
        .font(.body)
        .foregroundColor(.onSurfaceVariant.opacity(0.6))
        .multilineTextAlignment(.center)
}
.padding(.top, 100)
```

---

## 五、模块三：人物设定模块升级（SettingsView）

### 5.1 当前实现 vs 设计稿差异

| 元素 | 当前实现 | 设计稿要求 |
|------|---------|-----------|
| 人格头像 | SF Symbol 图标 (`person.crop.circle.fill`) | **真实头像图片**（圆形，64×64）|
| 头像交互 | 无特殊效果 | **灰度 ↔ 彩色切换**（未选中灰度，hover/选中彩色）|
| 选中状态 | 边框 + 背景色 | **边框 + Ring 光晕** (`border-primary/30 ring-1 ring-primary/20`)|
| 性别图标 | SF Symbols | 保持一致 ✅ |
| 国家选择 | Menu 组件 | 改为卡片内展示 + 「修改/Change」按钮 |
| 代谢速率 | Capsule 选择器 | 保持一致 ✅ |
| Footer | 简单文本 | 添加版本号 + About Druk 按钮 + 法律免责 |

### 5.2 实施步骤

#### Step 1: 升级人格档案选择器（SettingsPersonaSection）
```swift
// 视觉重构：
1. 替换图标为真实头像图片：
   - 准备 8 张头像资源（Martin, Nikolaj, Tommy, Peter, Clara, Elena, Maya, Sofia）
   - 存放到 Assets.xcassets 或使用 NetworkImage
   - 尺寸：w-16 h-16 (64×64pt)，rounded-full，overflow-hidden

2. 头像交互效果：
   - 未选中：grayscale (灰度) + opacity-40
   - hover：grayscale-0 过渡动画 (duration-700)
   - 选中：grayscale-0 + border-2 border-primary

3. 选中卡片样式：
   - glass-card 背景
   - border-primary/30
   - ring-1 ring-primary/20（外发光效果）

4. 性别切换逻辑：
   - 男性用户显示：Martin, Nikolaj, Tommy, Peter
   - 女性用户显示：Clara, Elena, Maya, Sofia
   - 添加性别切换按钮或自动检测
```

#### Step 2: 优化国家/地区选择器（SettingsJurisdictionSection）
```swift
// 交互重构：
1. 移除原生 Menu 组件
2. 改为卡片式展示：
   ┌─────────────────────────────────────┐
   │ 🌍  国家 / 地区 / Country           │
   │     China                          │
   │                    [修改 / Change] │
   ├─────────────────────────────────────┤
   │ 醉酒驾驶 / Drunk Driving    0.02%  │
   │ 饮酒驾驶阈值 / DUI Threshold 0.08% │
   └─────────────────────────────────────┘
3. 点击「修改」按钮弹出选择器（Sheet 或 FullScreenCover）
4. 在选择器中使用国旗 + 名称列表
```

#### Step 3: 完善 Footer 区域（SettingsFooterView）
```swift
// 内容增强：
VStack(spacing: 16) {
    // 版本号
    Text("Version 2.2")
        .font(.label)
        .tracking-widest
        .opacity(0.4)
    
    // About 按钮
    Button(action: { showAboutSheet = true }) {
        Text("About Druk")
            .font(.headline.italic)
    }
    
    // 链接组
    HStack(spacing: 24) {
        Link("Our Philosophy", destination: URL(string: "#")!)
        Link("Privacy", destination: URL(string: "#")!)
    }
    
    // 法律免责声明（多语言）
    Text("法律免责声明：酒精吸收与消除受显著生理差异影响...")
        .font(.body)
        .opacity(0.3)
        .multilineTextAlignment(.center)
    
    // Latin Proverb
    Text("\"In vino veritas, in aqua sanitas.\"")
        .font(.headline.italic)
}
```

#### Step 4: 添加 About 弹窗
```swift
// 新增 AboutDrukSheet:
┌─────────────────────────────────┐
│  Druk Logo                      │
│                                 │
│  Version 2.2                    │
│  © 2026 All Rights Reserved     │
│                                 │
│  ─────────────────────────────  │
│                                 │
│  致谢 / Acknowledgments:       │
│  · 电影《酒精计划》(2020)       │
│  · baccalculator.online         │
│  · Widmark Formula (1932)      │
│                                 │
│  ─────────────────────────────  │
│                                 │
│  [关闭 / Close]                 │
└─────────────────────────────────┘
```

---

## 六、共享组件升级

### 6.1 GlassCardModifier 增强
```swift
// 当前实现：
.background(Color.surfaceContainerHighest.opacity(0.4))
.background(.ultraThinMaterial)

// 升级为：
.background(Color.surfaceContainer.opacity(0.4))  // 使用 surface-container
.backdropFilter(.blur(radius: 20))  // 增强模糊半径
.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
.overlay(
    RoundedRectangle(cornerRadius: 16, style: .continuous)
        .stroke(Color.white.opacity(0.05), lineWidth: 1)  // Ghost Border
)
.shadow(color: .black.opacity(0.15), radius: 20, y: 10)  // Ambient Shadow
```

### 6.2 TopAppBar 组件统一
```swift
// 所有页面统一的顶部导航栏：
struct TavernTopAppBar: View {
    let title: String
    let showSettings: Bool
    
    var body: some View {
        HStack {
            // 左侧：头像 + Logo
            HStack(spacing: 12) {
                PersonaAvatar()  // 40×40 圆形头像
                Text("Druk")
                    .font(.headline.italic(size: 24))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // 右侧：设置按钮（如果需要）
            if showSettings {
                Button(action: {}) {
                    Image(systemName: "settings")
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .background(
            Color.surfaceDim.opacity(0.4)
                .background(.ultraThinMaterial)
                .background(
                    LinearGradient(
                        colors: [.surfaceContainerLow, .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
    }
}
```

### 6.3 BottomTabBar 样式优化
```swift
// Tab Bar 视觉升级：
UITabBarAppearance()
    .configureWithTransparentBackground()
    .backgroundColor = UIColor(Color.surfaceDim.opacity(0.8))
    .backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
    // 添加顶部圆角
    // 添加阴影: shadow-[0_-10px_40px_rgba(0,0,0,0.5)]
    // 添加顶部边框: border-t border-[#f0e6d3]/10
```

---

## 七、实施优先级与顺序

### Phase 1: 高优先级（核心视觉一致性）
1. ✅ **CurveView 重构** - 状态卡片 + 增强曲线图 + 统计卡片
2. ✅ **HistoryView 热力图** - 真实数据驱动 + 动态色块
3. ✅ **SettingsPersonaSection** - 真实头像 + 灰度切换效果

### Phase 2: 中优先级（交互体验提升）
4. ⚠️ **HistoryTimelineView** - 渐变时间线 + 发光圆点
5. ⚠️ **HistorySessionCard** - 信息层次优化
6. ⚠️ **SettingsJurisdictionSection** - 卡片式选择器

### Phase 3: 低优先级（锦上添花）
7. 🔄 **CinematicQuoteView** - 作者署名
8. 🔄 **AboutDrukSheet** - 关于弹窗
9. 🔄 **空状态设计** - 引导用户开始记录

---

## 八、技术要点与注意事项

### 8.1 图片资源管理
- 人格头像需要准备 8 张图片（建议 128×128 @2x = 256×256）
- 可以使用 AI 生成的角色肖像（参考 stitch 中的 Google Photos 链接）
- 或者使用 SF Symbols 的 person.crop.circle 作为 fallback

### 8.2 性能优化
- 热力图渲染：使用 LazyVGrid 避免一次性渲染 365+ 个视图
- 曲线图采样：保持每 10 分钟一个点，避免过度绘制
- 头像缓存：使用 AsyncImage 或缓存机制

### 8.3 动画性能
- 遵循 DESIGN.md 的原则：使用 slow fades (300ms+) 而非 snaps
- 灰度切换动画：700ms duration
- 卡片悬停：500ms transition

### 8.4 无障碍支持
- 所有动态颜色对比度需符合 WCAG AA 标准
- VoiceOver 标签：为新增的视觉元素添加 accessibilityLabel
- Dynamic Type：确保字体缩放后布局不破裂

---

## 九、验收标准

### CurveView
- [ ] 页面标题与设计稿完全一致
- [ ] 状态卡片正确显示当前 BAC 和状态
- [ ] 曲线图包含所有参考线（黄金点、DUI、DWI）
- [ ] 清醒时间和法定安全距离准确计算
- [ ] 统计卡片显示总摄入和峰值时间

### HistoryView
- [ ] 热力图基于真实 sessions 数据渲染
- [ ] 色块深度反映饮酒量等级
- [ ] 时间线有渐变和发光效果
- [ ] 记录卡片显示完整信息（日期、标签、峰值、宿醉）
- [ ] 台词引用包含作者署名

### SettingsView
- [ ] 人格档案显示真实头像（或高质量占位符）
- [ ] 头像支持灰度/彩色切换动画
- [ ] 选中状态有明显的光晕效果
- [ ] 国家选择器改为卡片式交互
- [ ] Footer 包含完整的信息和免责声明

---

## 十、文件修改清单

### 主要修改文件
1. `ContentView.swift`
   - CurveView 结构体重构
   - HistoryView 子组件升级
   - SettingsView 各 Section 增强
   - 新增共享组件（TavernTopAppBar, CinematicQuoteView 等）

### 可能的新增文件
2. `PersonaAssets.swift` - 人格头像资源管理
3. `HeatMapGrid.swift` - 热力图计算逻辑
4. `AboutDrukSheet.swift` - 关于弹窗

### 资源文件
5. `Assets.xcassets`
   - 新增 8 张人格头像图片
   - 可能需要的图标资源

---

*文档结束 · 计划完成 · 准备执行*
