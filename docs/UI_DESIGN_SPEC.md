# Seclib AI Desktop - UI/UX Design Specification

## 🎨 Design Philosophy

**Claude-Inspired Premium AI Experience**
- Minimal, elegant, and calm interface
- Highly readable typography and spacing
- Professional polish with subtle animations
- Focus on conversation flow and user comfort
- No developer artifacts or technical complexity visible

## 🎯 Core Layout Architecture

### Main Layout Structure
```
┌─────────────────────────────────────────────────┐
│ ┌─────────────┐ ┌─────────────────────────────┐ │
│ │   SIDEBAR   │ │         MAIN AREA           │ │
│ │   (280px)   │ │                             │ │
│ │             │ │ ┌─────────────────────────┐ │ │
│ │  • Chats    │ │ │      CHAT AREA          │ │ │
│ │  • Knowledge│ │ │    (conversation)      │ │ │
│ │  • Skills   │ │ │                         │ │ │
│ │  • Settings │ │ └─────────────────────────┘ │ │
│ │             │ │                             │ │ │
│ │             │ │ ┌─────────────────────────┐ │ │
│ │             │ │ │     INPUT BAR           │ │ │
│ │             │ │ │   (floating style)      │ │ │
│ └─────────────┘ └─────────────────────────┘ │ │
└─────────────────────────────────────────────────┘
```

### Layout Specifications
- **Window**: 1200x800px minimum, resizable
- **Sidebar**: Fixed 280px width, full height
- **Main Area**: Flex-grow, full height minus input bar
- **Input Bar**: Fixed height 80px, floating at bottom
- **Spacing**: 24px base unit throughout

## 🎨 Design System

### Color Palette (Claude-Inspired Neutral)
```css
/* Primary Colors */
--color-bg-primary: #ffffff;
--color-bg-secondary: #fafafa;
--color-bg-tertiary: #f5f5f5;

/* Text Colors */
--color-text-primary: #1a1a1a;
--color-text-secondary: #666666;
--color-text-tertiary: #999999;

/* Accent Colors */
--color-accent-primary: #7c3aed;    /* Purple accent */
--color-accent-secondary: #a855f7;
--color-accent-light: #f3f4f6;

/* Message Colors */
--color-user-message: #7c3aed;
--color-assistant-message: #ffffff;
--color-assistant-border: #e5e7eb;

/* Interactive States */
--color-hover: #f9fafb;
--color-active: #f3f4f6;
--color-focus: #7c3aed;
--color-focus-ring: rgba(124, 58, 237, 0.1);
```

### Typography Scale
```css
/* Font Family */
--font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;

/* Font Sizes */
--text-xs: 12px;    /* Small labels */
--text-sm: 14px;    /* Body text */
--text-base: 16px;  /* Main content */
--text-lg: 18px;    /* Large text */
--text-xl: 20px;    /* Headings */
--text-2xl: 24px;   /* Section headers */
--text-3xl: 30px;   /* Page titles */

/* Font Weights */
--font-light: 300;
--font-normal: 400;
--font-medium: 500;
--font-semibold: 600;
--font-bold: 700;

/* Line Heights */
--leading-tight: 1.25;
--leading-normal: 1.5;
--leading-relaxed: 1.75;
```

### Spacing Scale (8px Base)
```css
--space-1: 4px;     /* Minimal spacing */
--space-2: 8px;     /* Component padding */
--space-3: 12px;    /* Small gaps */
--space-4: 16px;    /* Standard spacing */
--space-5: 20px;    /* Medium spacing */
--space-6: 24px;    /* Large spacing */
--space-8: 32px;    /* Section spacing */
--space-10: 40px;   /* Major sections */
--space-12: 48px;   /* Page sections */
```

### Border Radius Scale
```css
--radius-sm: 6px;   /* Small elements */
--radius-md: 8px;   /* Buttons, inputs */
--radius-lg: 12px;  /* Cards, modals */
--radius-xl: 16px;  /* Large containers */
--radius-2xl: 20px; /* Special elements */
```

### Shadows (Soft & Subtle)
```css
--shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
--shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
--shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
--shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
```

## 🧩 Component Structure

### 1. Sidebar Component (`<Sidebar />`)

#### Visual Design
- **Background**: Solid white with subtle border-right
- **Width**: 280px fixed
- **Padding**: 24px top/bottom, 20px left/right
- **Border**: 1px solid #e5e7eb on right edge

#### Navigation Items
```jsx
const navItems = [
  { id: 'chat', label: 'Chats', icon: '💬' },
  { id: 'knowledge', label: 'Knowledge', icon: '📚' },
  { id: 'skills', label: 'Skills', icon: '⚡' },
  { id: 'settings', label: 'Settings', icon: '⚙️' }
];
```

#### Item Styling
- **Height**: 44px
- **Padding**: 12px horizontal, 8px vertical
- **Border Radius**: 8px
- **Typography**: 16px medium weight
- **Icon**: 20px, 16px spacing from text
- **Active State**: Purple background (#7c3aed), white text
- **Hover State**: Light gray background (#f9fafb)

#### New Chat Button
- **Position**: Bottom of sidebar
- **Style**: Primary button (purple background)
- **Text**: "+ New Chat"
- **Full Width**: Matches nav item width

### 2. Chat Area Component (`<ChatArea />`)

#### Layout
- **Background**: #fafafa (subtle gray)
- **Padding**: 24px all sides
- **Scroll**: Smooth auto-scroll to bottom
- **Max Width**: 800px, centered

#### Message Bubbles

##### User Messages
- **Background**: Linear gradient #7c3aed to #a855f7
- **Text Color**: White
- **Border Radius**: 18px (more rounded)
- **Padding**: 16px 20px
- **Max Width**: 70% of container
- **Float**: Right aligned
- **Margin**: 12px bottom, auto left margin

##### Assistant Messages
- **Background**: White
- **Border**: 1px solid #e5e7eb
- **Border Radius**: 16px
- **Padding**: 20px 24px
- **Max Width**: 85% of container
- **Float**: Left aligned
- **Box Shadow**: Subtle shadow-md
- **Margin**: 16px bottom

#### Streaming Animation
- **Typing Indicator**: Three pulsing dots
- **Background**: Same as assistant message
- **Animation**: Smooth pulse with stagger
- **Duration**: 1.5s cycle

#### Code Blocks
- **Background**: #f8fafc (very light blue-gray)
- **Border**: 1px solid #e2e8f0
- **Border Radius**: 8px
- **Padding**: 16px
- **Font**: Monospace, 14px
- **Line Numbers**: Optional, subtle gray
- **Copy Button**: Top-right, ghost style
- **Syntax Highlighting**: Subtle colors

#### Knowledge Citations
- **Style**: Small superscript numbers [1]
- **Color**: #7c3aed
- **Hover**: Shows tooltip with source info
- **Position**: Inline with text

### 3. Input Bar Component (`<InputBar />`)

#### Container
- **Position**: Fixed bottom, full width
- **Background**: White with blur effect
- **Border Top**: 1px solid #e5e7eb
- **Padding**: 16px 24px
- **Box Shadow**: Subtle upward shadow
- **Backdrop Filter**: blur(8px)

#### Input Field
- **Height**: 48px minimum, auto-grow to 120px
- **Border Radius**: 24px (fully rounded)
- **Border**: 2px solid #e5e7eb
- **Padding**: 12px 20px
- **Font Size**: 16px
- **Line Height**: 1.5
- **Focus**: Purple border (#7c3aed), focus ring
- **Placeholder**: "Ask me anything..."

#### Send Button
- **Position**: Inside input, right side
- **Size**: 36px diameter
- **Background**: #7c3aed
- **Border Radius**: 18px
- **Icon**: Send arrow (→)
- **Hover**: Darker purple
- **Disabled**: Gray, reduced opacity

#### Attachment Button
- **Position**: Left of input
- **Style**: Ghost button
- **Icon**: Paperclip
- **Hover**: Light gray background

### 4. Knowledge Tab Component (`<KnowledgeTab />`)

#### Header
- **Title**: "Knowledge Base"
- **Subtitle**: "Upload documents to enhance AI responses"
- **Layout**: Centered, 32px margin bottom

#### Upload Area
- **Style**: Large dashed border dropzone
- **Size**: 400x200px minimum
- **Border**: 2px dashed #cbd5e1
- **Border Radius**: 12px
- **Background**: #f8fafc on hover
- **Icon**: Large document icon
- **Text**: "Drop files here or click to browse"
- **Supported Formats**: PDF, TXT, MD, DOCX

#### File List
- **Layout**: Grid or list view
- **Item Style**: Card with file icon, name, size, status
- **Status Indicators**: Processing, Ready, Error
- **Actions**: Remove button (×)
- **Progress Bar**: For indexing progress

#### Knowledge Usage Indicator
- **Position**: Bottom of chat messages
- **Style**: Subtle gray text
- **Content**: "Using 3 knowledge sources"
- **Expandable**: Click to see source list

### 5. Skills Tab Component (`<SkillsTab />`)

#### Header
- **Title**: "AI Skills"
- **Subtitle**: "Enable specialized capabilities"
- **Add Button**: Primary style, top-right

#### Skills Grid
- **Layout**: 2-3 columns responsive grid
- **Card Style**: White background, subtle shadow
- **Size**: 280x160px
- **Border Radius**: 12px
- **Padding**: 20px

#### Skill Card Content
- **Icon**: Large, colored icon (⚡, 🔍, 📝, etc.)
- **Title**: Skill name, 18px semibold
- **Description**: 2-3 lines, 14px gray
- **Toggle**: iOS-style switch, top-right
- **Status**: "Active" badge when enabled

#### Add Skill Modal
- **Title**: "Add New Skill"
- **Form Fields**:
  - Name (text input)
  - Description (textarea)
  - Category (select dropdown)
  - File upload (JSON skill file)
- **Buttons**: Cancel (secondary), Add (primary)

### 6. Settings Tab Component (`<SettingsTab />`)

#### Layout
- **Sections**: Grouped settings with headers
- **Spacing**: 32px between sections

#### Settings Groups
1. **AI Model**: Model selection dropdown
2. **Privacy**: Data retention toggles
3. **Appearance**: Theme selection
4. **Performance**: Memory usage settings
5. **About**: Version info, links

#### Form Controls
- **Dropdowns**: Custom styled with chevron
- **Toggles**: iOS-style switches
- **Buttons**: Primary/secondary variants
- **Inputs**: Consistent with input bar style

## 🎭 Animation System

### Micro-Interactions
- **Hover States**: 150ms ease-out transitions
- **Focus States**: Smooth border color change
- **Button Press**: Scale down 95%, 100ms
- **Message Appear**: Slide up with fade, 300ms

### Page Transitions
- **Tab Switch**: Crossfade between tabs, 200ms
- **Modal Open**: Scale in from 95%, fade in, 250ms
- **Loading States**: Smooth progress bars, pulsing elements

### Streaming Animation
- **Typing Dots**: Staggered pulse animation
- **Message Stream**: Character-by-character reveal
- **Progress Bars**: Smooth fill animation

## 📱 Responsive Design

### Breakpoints
- **Desktop**: > 1024px (full layout)
- **Tablet**: 768px - 1024px (compact sidebar)
- **Mobile**: < 768px (stacked layout, collapsible sidebar)

### Mobile Adaptations
- **Sidebar**: Collapsible drawer
- **Messages**: Full width, adjusted padding
- **Input Bar**: Fixed bottom, full width
- **Touch Targets**: Minimum 44px height

## ♿ Accessibility

### Standards
- **WCAG 2.1 AA** compliance
- **Keyboard Navigation**: Full support
- **Screen Reader**: Proper ARIA labels
- **Color Contrast**: 4.5:1 minimum ratio
- **Focus Indicators**: Visible focus rings

### Implementation
- **Semantic HTML**: Proper heading hierarchy
- **ARIA Labels**: Descriptive labels for icons
- **Keyboard Shortcuts**: Standard shortcuts (Ctrl+N for new chat)
- **High Contrast**: Support for system preferences

## 🛠️ Technical Implementation

### React Component Architecture
```jsx
// Main App Structure
<App>
  <Sidebar />
  <MainArea>
    <ChatArea />
    <InputBar />
    <KnowledgeTab />
    <SkillsTab />
    <SettingsTab />
  </MainArea>
</App>
```

### State Management
- **Local State**: React useState for UI state
- **Global State**: Context API for app-wide settings
- **IPC Communication**: Electron API for backend calls

### Styling Approach
- **CSS Variables**: Design system tokens
- **Component-Scoped**: CSS modules or styled-components
- **Utility Classes**: Consistent spacing, colors
- **Dark Mode Ready**: CSS custom properties for themes

### Performance Optimizations
- **Virtual Scrolling**: For long chat histories
- **Lazy Loading**: For tab content
- **Memoization**: React.memo for expensive components
- **Bundle Splitting**: Code splitting by route

## 🎯 Implementation Priority

### Phase 1: Core Chat Experience
1. Sidebar navigation
2. Message bubbles with proper styling
3. Input bar with floating design
4. Basic streaming animation

### Phase 2: Knowledge Integration
1. Drag & drop upload area
2. File processing indicators
3. Knowledge usage display
4. Source management

### Phase 3: Skills System
1. Skills grid layout
2. Toggle controls
3. Add skill modal
4. Skill status indicators

### Phase 4: Polish & Animation
1. Smooth transitions
2. Loading states
3. Error handling
4. Accessibility features

This design specification provides a comprehensive blueprint for creating a Claude-like interface that feels premium, professional, and focused on the user experience rather than technical complexity.</content>
<parameter name="filePath">/home/fatsio/rag-engine/UI_DESIGN_SPEC.md