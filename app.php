<?php
session_start();
header('Content-Type: text/html; charset=utf-8');

$LOGIN_USER = 'gejie';
$LOGIN_PASS = '2026888';

// 下面的代码全部保持不变

if (isset($_GET['logout']) && $_GET['logout'] === '1') {
    $_SESSION = [];
    if (ini_get('session.use_cookies')) {
        $params = session_get_cookie_params();
        setcookie(session_name(), '', time() - 42000, $params['path'], $params['domain'], $params['secure'], $params['httponly']);
    }
    session_destroy();
    header('Location: app.php');
    exit;
}

if (($_SESSION['admin_authed'] ?? false) !== true) {
    $err = '';
    if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'POST') {
        $u = trim((string)($_POST['username'] ?? ''));
        $p = trim((string)($_POST['password'] ?? ''));
        if (hash_equals($LOGIN_USER, $u) && hash_equals($LOGIN_PASS, $p)) {
            $_SESSION['admin_authed'] = true;
            $_SESSION['admin_user'] = $LOGIN_USER;
            header('Location: app.php');
            exit;
        }
        $err = '账号或密码错误';
    }
    ?>
<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>后台登录</title>
  <style>
    :root {
      --panel: rgba(255, 255, 255, .14);
      --panel-border: rgba(255, 255, 255, .22);
      --text: #f8fafc;
      --muted: rgba(248, 250, 252, .72);
      --accent: #60a5fa;
      --accent-2: #22d3ee;
      --danger: #fecaca;
      --shadow: 0 20px 50px rgba(15, 23, 42, .22);
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      font-family: -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Helvetica,Arial,"PingFang SC","Microsoft YaHei",sans-serif;
      background:
        linear-gradient(135deg, rgba(15, 23, 42, .35), rgba(37, 99, 235, .15)),
        url('bj.jpeg') no-repeat center center;
      background-size: cover;
      color: var(--text);
    }
    .login-shell {
      width: min(92vw, 420px);
      padding: 18px;
    }
    .login-box {
      width: 100%;
      padding: 30px;
      color: var(--text);
      background: var(--panel);
      border: 1px solid var(--panel-border);
      border-radius: 24px;
      box-shadow: var(--shadow);
      backdrop-filter: blur(18px) saturate(140%);
      -webkit-backdrop-filter: blur(18px) saturate(140%);
    }
    .login-title {
      margin: 0;
      font-size: 28px;
      font-weight: 800;
      letter-spacing: .02em;
      text-align: center;
    }
    .login-subtitle {
      margin: 10px 0 0;
      text-align: center;
      color: var(--muted);
      font-size: 14px;
      line-height: 1.6;
    }
    .login-fields { margin-top: 22px; display: grid; gap: 12px; }
    input {
      width: 100%;
      height: 48px;
      padding: 0 14px;
      border-radius: 14px;
      border: 1px solid rgba(255,255,255,.16);
      background: rgba(15, 23, 42, .2);
      color: #fff;
      outline: none;
      transition: border-color .18s ease, box-shadow .18s ease, background .18s ease;
    }
    input::placeholder { color: rgba(255,255,255,.7); }
    input:focus {
      border-color: rgba(96, 165, 250, .9);
      box-shadow: 0 0 0 4px rgba(96, 165, 250, .18);
      background: rgba(15, 23, 42, .28);
    }
    button {
      margin-top: 18px;
      width: 100%;
      height: 48px;
      border: 0;
      border-radius: 14px;
      color: #fff;
      font-size: 15px;
      font-weight: 700;
      background: linear-gradient(135deg, #2563eb 0%, #22d3ee 100%);
      box-shadow: 0 14px 30px rgba(37, 99, 235, .28);
      cursor: pointer;
      transition: transform .18s ease, box-shadow .18s ease, opacity .18s ease;
    }
    button:hover { transform: translateY(-1px); box-shadow: 0 18px 36px rgba(37, 99, 235, .34); }
    button:active { transform: translateY(0); opacity: .92; }
    .err { margin-top: 12px; color: var(--danger); font-size: 13px; text-align: center; }
  </style>
</head>
<body>
  <div class="login-shell">
    <form class="login-box" method="post" action="app.php" autocomplete="off">
      <h2 class="login-title">管理后台登录</h2>
      <p class="login-subtitle">欢迎回来，请先验证身份后进入管理面板。</p>
      <div class="login-fields">
        <input type="text" name="username" placeholder="账号" required />
        <input type="password" name="password" placeholder="密码" required />
      </div>
      <button type="submit">登 录</button>
      <?php if ($err !== ''): ?>
        <div class="err"><?= htmlspecialchars($err, ENT_QUOTES, 'UTF-8') ?></div>
      <?php endif; ?>
    </form>
  </div>
</body>
</html>
<?php
    exit;
}
?>
<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>账号管理后台</title>
  <style>
    :root {
      --bg: #f7f8fb;
      --surface: #ffffff;
      --surface-soft: #fbfcfe;
      --text: #111827;
      --muted: #6b7280;
      --line: #e5e7eb;
      --primary: #2563eb;
      --primary-2: #0ea5e9;
      --danger: #ef4444;
      --shadow: 0 10px 30px rgba(15, 23, 42, .06);
      --radius-xl: 20px;
      --radius-lg: 16px;
      --radius-md: 12px;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      color: var(--text);
      font-family: -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Helvetica,Arial,"PingFang SC","Microsoft YaHei",sans-serif;
      background: var(--bg);
      min-height: 100vh;
    }
    .app-shell {
      max-width: 1440px;
      margin: 0 auto;
      padding: 20px;
      display: grid;
      grid-template-columns: 260px minmax(0, 1fr);
      gap: 16px;
      min-height: 100vh;
      transition: grid-template-columns .22s ease;
    }
    .app-shell.sidebar-collapsed { grid-template-columns: 88px minmax(0, 1fr); }
    .sidebar, .panel, .card, .topbar, .stat, .side-panel-card, .mini-stat {
      background: var(--surface);
      border: 1px solid var(--line);
      box-shadow: var(--shadow);
    }
    .sidebar {
      border-radius: var(--radius-xl);
      padding: 18px;
      position: sticky;
      top: 20px;
      height: fit-content;
      transition: padding .22s ease, transform .22s ease;
    }
    .app-shell.sidebar-collapsed .sidebar { padding: 18px 12px; }
    .app-shell.sidebar-collapsed .brand p,
    .app-shell.sidebar-collapsed .nav-item span,
    .app-shell.sidebar-collapsed .meta-card .k,
    .app-shell.sidebar-collapsed .footer-note { display: none; }
    .app-shell.sidebar-collapsed .brand h1 { font-size: 18px; line-height: 1.2; }
    .app-shell.sidebar-collapsed .nav-list { gap: 8px; }
    .app-shell.sidebar-collapsed .nav-item { padding: 12px 10px; text-align: center; justify-content: center; }
    .app-shell.sidebar-collapsed .nav-item::after { display: none; }
    .brand {
      display: flex;
      flex-direction: column;
      gap: 8px;
      padding-bottom: 14px;
      border-bottom: 1px solid var(--line);
      margin-bottom: 14px;
    }
    .topbar {
      border-radius: var(--radius-xl);
      padding: 16px 18px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 16px;
      flex-wrap: wrap;
    }
    .topbar-left, .topbar-right { display: flex; align-items: center; gap: 14px; flex-wrap: wrap; }
    .topbar-title { font-size: 18px; font-weight: 800; }
    .topbar-btn, .topbar-link {
      height: 38px;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      padding: 0 14px;
      border-radius: 12px;
      border: 1px solid #dbe6ff;
      background: #eef4ff;
      color: #2451d4;
      text-decoration: none;
      font-size: 13px;
      font-weight: 700;
      cursor: pointer;
      box-shadow: none;
    }
    .topbar-link { background: #fff; }
    .brand h1 { margin: 0; font-size: 24px; letter-spacing: .02em; }
    .brand p { margin: 0; color: var(--muted); font-size: 13px; line-height: 1.6; }
    .nav-list { display: grid; gap: 8px; }
    .nav-item {
      border-radius: 12px;
      padding: 12px 14px;
      background: var(--surface-soft);
      border: 1px solid transparent;
      color: var(--text);
      font-size: 14px;
      font-weight: 600;
      cursor: pointer;
      transition: all .18s ease;
      display: flex;
      align-items: center;
      justify-content: space-between;
      user-select: none;
    }
    .nav-item::after {
      content: '›';
      color: var(--muted);
      font-size: 18px;
      line-height: 1;
    }
    .nav-item:hover {
      background: #f3f7ff;
      border-color: #dbe6ff;
      transform: translateX(2px);
    }
    .nav-item.active {
      background: #eff6ff;
      border-color: #bfdbfe;
      color: #1d4ed8;
    }
    .nav-item.active::after { color: #1d4ed8; }
    .nav-meta { margin-top: 18px; display: grid; gap: 10px; }
    .meta-card {
      border-radius: 14px;
      padding: 12px 14px;
      background: var(--surface-soft);
      border: 1px solid var(--line);
    }
    .meta-card .k { display:block; color: var(--muted); font-size: 12px; margin-bottom: 6px; }
    .meta-card .v { font-size: 16px; font-weight: 700; }
    .main { display: grid; gap: 16px; }
    .hero {
      border-radius: var(--radius-xl);
      padding: 14px 18px;
      background: var(--surface);
      color: var(--text);
      border: 1px solid var(--line);
      box-shadow: var(--shadow);
    }
    .hero-top { display:flex; justify-content:space-between; gap: 16px; align-items:center; flex-wrap: wrap; }
    .hero-actions { display:flex; gap: 10px; align-items:center; flex-wrap: wrap; }
    .chip, .tag {
      display:inline-flex; align-items:center; gap: 6px;
      padding: 8px 12px; border-radius: 999px; font-size: 12px; font-weight: 700;
      background: #f8fafc; color: #334155; border: 1px solid var(--line);
    }
    .panel, .card {
      border-radius: var(--radius-xl);
      padding: 18px;
    }
    .section-title {
      display:flex; justify-content:space-between; align-items:center; gap: 12px; flex-wrap: wrap;
      margin-bottom: 10px;
    }
    .section-title h3 { margin: 0; font-size: 18px; }
    .grid-2 { display:grid; grid-template-columns: 1.15fr .85fr; gap: 16px; align-items: stretch; }
    .grid-3 { display:grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 12px; }
    .stat {
      border-radius: 16px; padding: 14px; background: var(--surface); border: 1px solid var(--line);
    }
    .side-panel {
      display: grid;
      grid-template-rows: auto 1fr;
      gap: 14px;
      min-height: 100%;
    }
    .side-panel-card {
      border-radius: 16px;
      background: var(--surface);
      border: 1px solid var(--line);
      padding: 14px;
      box-shadow: none;
    }
    .mini-title {
      font-size: 13px;
      font-weight: 800;
      letter-spacing: .02em;
      margin: 0 0 12px;
      color: var(--text);
    }
    .mini-grid {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 10px;
    }
    .mini-stat {
      border-radius: 12px;
      padding: 12px;
      background: var(--surface-soft);
      border: 1px solid var(--line);
    }
    .mini-stat .k { font-size: 12px; color: var(--muted); }
    .mini-stat .v { margin-top: 8px; font-size: 20px; font-weight: 800; color: var(--text); }
    .stat .k { color: var(--muted); font-size: 12px; }
    .stat .v { margin-top: 8px; font-size: 24px; font-weight: 800; }
    .row { display:flex; gap: 12px; align-items:center; flex-wrap: wrap; }
    .grow { flex: 1; min-width: 220px; }
    input, button, textarea {
      border: 1px solid #dbe4f0;
      border-radius: 14px;
      font-size: 14px;
      outline: none;
      background: rgba(255,255,255,.98);
      transition: border-color .18s ease, box-shadow .18s ease, transform .18s ease;
    }
    input, button { height: 44px; padding: 0 14px; }
    input:focus, textarea:focus { border-color: rgba(37, 99, 235, .9); box-shadow: 0 0 0 4px rgba(37, 99, 235, .10); }
    button {
      cursor: pointer; color: #fff; border: none;
      background: linear-gradient(135deg, var(--primary) 0%, var(--primary-2) 100%);
      box-shadow: 0 12px 24px rgba(37, 99, 235, .16); font-weight: 700;
    }
    button:hover { transform: translateY(-1px); }
    button.ghost { background: #eef4ff; color: #2451d4; border: 1px solid #dbe6ff; box-shadow: none; }
    button.danger { background: #fee2e2; color: var(--danger); border: 1px solid #fecaca; box-shadow: none; }
    textarea { width: 100%; min-height: 140px; padding: 12px 14px; resize: vertical; background: rgba(255,255,255,.98); font-family: inherit; line-height: 1.6; }
    table { width: 100%; border-collapse: collapse; overflow: hidden; }
    th, td { border-bottom: 1px solid var(--line); padding: 13px 10px; font-size: 14px; text-align: left; vertical-align: middle; }
    th { color: var(--muted); font-weight: 800; font-size: 12px; text-transform: uppercase; letter-spacing: .04em; }
    tr:hover td { background: rgba(248, 250, 252, .9); }
    .num { text-align: right; }
    .tag.secondary { background: #eef4ff; color: #2451d4; border: 1px solid #dbe6ff; }
    .topbar-pill {
      display:inline-flex; align-items:center; gap:6px;
      height: 36px; padding: 0 12px; border-radius: 999px;
      background: var(--surface); border: 1px solid var(--line); color: var(--muted); font-size: 12px; font-weight: 700;
    }
    .link-list { display: grid; gap: 10px; }
    .link-item { border: 1px solid var(--line); background: linear-gradient(180deg, #fff 0%, #f9fbff 100%); border-radius: 16px; padding: 14px; font-size: 13px; }
    .link-item a { color: #1d4ed8; word-break: break-all; text-decoration: none; }
    .link-item a:hover { text-decoration: underline; }
    .empty { color: var(--muted); padding: 14px 4px; }
    .toolbar { display:flex; gap: 10px; align-items:center; flex-wrap: wrap; }
    @media (max-width: 1180px) {
      .app-shell { grid-template-columns: 1fr; }
      .sidebar { position: static; }
      .grid-2, .grid-3 { grid-template-columns: 1fr; }
    }
    @media (max-width: 640px) {
      .app-shell { padding: 14px; }
      .hero h2 { font-size: 24px; }
      .panel, .card, .hero, .sidebar { border-radius: 22px; }
    }
  </style>
</head>
<body>
<div class="app-shell" id="appShell">
  <aside class="sidebar" id="sidebar">
    <div class="brand">
      <h1>账号管理后台</h1>
    </div>
    <div class="nav-list">
      <div class="nav-item active" data-target="section-overview"><span>概览中心</span></div>
      <div class="nav-item" data-target="section-account"><span>账号管理</span></div>
      <div class="nav-item" data-target="section-batch"><span>批量录入</span></div>
      <div class="nav-item" data-target="section-links"><span>链接生成</span></div>
      <div class="nav-item" data-target="section-update"><span>版本更新</span></div>
    </div>
    <div class="nav-meta">
      <div class="meta-card">
        <span class="k">当前用户</span>
        <span class="v"><?= htmlspecialchars((string)($_SESSION['admin_user'] ?? 'admin'), ENT_QUOTES, 'UTF-8') ?></span>
      </div>
      <div class="meta-card">
        <span class="k">登录状态</span>
        <span class="v">已验证</span>
      </div>
      <div class="meta-card">
        <a href="app.php?logout=1" style="text-decoration:none;color:inherit;display:block;">退出登录</a>
      </div>
    </div>
  </aside>

  <main class="main">
    <header class="topbar">
      <div class="topbar-left">
        <button id="btnToggleSidebar" class="topbar-btn">折叠侧边栏</button>
      </div>
      <div class="topbar-right">
        <span class="topbar-pill">当前用户：<?= htmlspecialchars((string)($_SESSION['admin_user'] ?? 'admin'), ENT_QUOTES, 'UTF-8') ?></span>
        <a class="topbar-link" href="app.php?logout=1">退出</a>
      </div>
    </header>

    <section class="hero" id="section-overview">
      <div class="hero-top">
        <div class="hero-actions">
          <span class="tag">控制台概览</span>
        </div>
      </div>
    </section>

    <section class="grid-3">
      <div class="stat">
        <span class="k">统计日期</span>
        <div class="v" id="sumDate">-</div>
      </div>
      <div class="stat">
        <span class="k">当日活跃账号</span>
        <div class="v" id="sumUsers">0</div>
      </div>
      <div class="stat">
        <span class="k">当日总上传</span>
        <div class="v" id="sumTotal">0</div>
      </div>
    </section>

    <section class="panel">
      <div class="section-title">
        <div>
          <h3>筛选与搜索</h3>
        </div>
      </div>
      <div class="toolbar">
        <input id="statDate" type="date" />
        <input class="grow" id="searchKeyword" type="text" placeholder="按账号或备注搜索" />
        <button id="btnSearch" class="ghost">搜索</button>
        <button id="btnToday" class="ghost">今天</button>
        <button id="btnBackfill" class="ghost">补齐未建档账号</button>
        <label class="tag secondary" style="cursor:pointer;">
          <input id="includeZero" type="checkbox" style="height:auto;" />
          包含0数量账号
        </label>
        <button id="btnReset" class="ghost">重置</button>
      </div>
    </section>

    <section class="grid-2" id="section-account">
      <div class="card">
        <div class="section-title">
          <div>
            <h3>账号录入</h3>
          </div>
        </div>
        <div class="row">
          <input id="formId" type="hidden" />
          <input class="grow" id="formAccount" type="text" placeholder="账号（必填）" />
          <input class="grow" id="formRemark" type="text" placeholder="备注（可为空）" />
          <button id="btnSave">新增 / 保存</button>
          <button id="btnClear" class="ghost">清空</button>
        </div>
      </div>

      <div class="side-panel">
        <div class="side-panel-card">
          <div class="mini-title">今日概览</div>
          <div class="mini-grid">
            <div class="mini-stat">
              <div class="k">统计日期</div>
              <div class="v" id="sumDateSide">-</div>
            </div>
            <div class="mini-stat">
              <div class="k">活跃账号</div>
              <div class="v" id="sumUsersSide">0</div>
            </div>
            <div class="mini-stat">
              <div class="k">总上传</div>
              <div class="v" id="sumTotalSide">0</div>
            </div>
            <div class="mini-stat">
              <div class="k">当前状态</div>
              <div class="v">正常</div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <section class="panel" id="section-batch">
      <div class="section-title">
        <div>
          <h3>批量添加账号</h3>
        </div>
      </div>
      <div class="row" style="margin-bottom:10px;">
        <input class="grow" id="batchRemark" type="text" placeholder="统一备注（可为空）" />
        <button id="btnBatchSave">批量添加</button>
        <button id="btnBatchClear" class="ghost">清空文本</button>
      </div>
      <textarea id="batchAccounts" placeholder="示例：&#10;account_001&#10;account_002&#10;account_003"></textarea>
    </section>

    <section class="panel" id="section-links">
      <div class="section-title">
        <div>
          <h3>账号列表</h3>
        </div>
        <button id="btnGenLinks">生成查询链接</button>
      </div>
      <table>
        <thead>
        <tr>
          <th style="width:40px;"><input type="checkbox" id="checkAll" /></th>
          <th style="width:70px;">ID</th>
          <th>账号</th>
          <th>备注</th>
          <th class="num" style="width:140px;">当日上传数</th>
          <th style="width:170px;">更新时间</th>
          <th style="width:150px;">操作</th>
        </tr>
        </thead>
        <tbody id="accountTbody"></tbody>
      </table>
      <div id="accountEmpty" class="empty" style="display:none;">暂无账号数据</div>
    </section>

    <section class="panel">
      <div class="section-title">
        <div>
          <h3>生成结果</h3>
        </div>
      </div>
      <div id="linksBox" class="link-list"></div>
      <div id="linksEmpty" class="empty">还未生成查询链接</div>
    </section>

    <section class="panel" id="section-update">
      <div class="section-title">
        <div>
          <h3>APP 在线更新</h3>
        </div>
      </div>
      <div class="row" style="margin-bottom:10px;">
        <input id="updVersion" type="text" placeholder="最新版本号，如 1.2.3" style="width:180px;" />
        <label class="tag secondary" style="cursor:pointer;">
          <input id="updForce" type="checkbox" style="height:auto;" />
          强制更新
        </label>
        <input class="grow" id="updApkUrl" type="text" placeholder="APK下载地址（可先上传后自动填充）" />
        <button id="btnUpdSave">保存更新配置</button>
        <button id="btnUpdReload" class="ghost">刷新配置</button>
      </div>
      <textarea id="updNotes" placeholder="更新说明（可选）"></textarea>
      <div class="row" style="margin-top:10px;">
        <input id="updApkFile" type="file" accept=".apk,application/vnd.android.package-archive" />
        <button id="btnUpdUpload" class="ghost">上传 APK 并填充地址</button>
      </div>
      <div class="hint" id="updStatus" style="margin-top:4px;">状态：未加载</div>
    </section>
  </main>
</div>

<script>
  const appShell = document.getElementById('appShell');
  const btnToggleSidebar = document.getElementById('btnToggleSidebar');
  const navItems = Array.from(document.querySelectorAll('.nav-item[data-target]'));
  const sectionMap = {};
  navItems.forEach(item => {
    const target = document.getElementById(item.dataset.target);
    if (target) sectionMap[item.dataset.target] = target;
    item.addEventListener('click', () => {
      navItems.forEach(n => n.classList.remove('active'));
      item.classList.add('active');
      const el = sectionMap[item.dataset.target];
      if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });
  });
  let sidebarCollapsed = false;
  btnToggleSidebar.addEventListener('click', () => {
    sidebarCollapsed = !sidebarCollapsed;
    appShell.classList.toggle('sidebar-collapsed', sidebarCollapsed);
    btnToggleSidebar.textContent = sidebarCollapsed ? '展开侧边栏' : '折叠侧边栏';
  });
  async function parseApiResponse(res) {
    const text = await res.text();
    let json = null;
    try {
      json = JSON.parse(text);
    } catch (_) {
      const snippet = String(text || '').slice(0, 220).replace(/\s+/g, ' ').trim();
      throw new Error(`接口返回非JSON（HTTP ${res.status}）：${snippet || 'empty response'}`);
    }

    if (!res.ok) {
      throw new Error(json.msg || `HTTP ${res.status}`);
    }
    if (!json || typeof json !== 'object') {
      throw new Error('接口返回格式错误');
    }
    if (json.code !== 0) {
      throw new Error(json.msg || '请求失败');
    }
    return json.data;
  }

  async function apiGet(action, params = {}) {
    const q = new URLSearchParams({ action, ...params });
    const res = await fetch(`upload_count_api.php?${q.toString()}`, { cache: 'no-store' });
    return parseApiResponse(res);
  }

  async function apiPost(action, data = {}) {
    const res = await fetch(`upload_count_api.php?action=${encodeURIComponent(action)}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });
    return parseApiResponse(res);
  }

  async function apiPostForm(action, formData) {
    const res = await fetch(`upload_count_api.php?action=${encodeURIComponent(action)}`, {
      method: 'POST',
      body: formData,
    });
    return parseApiResponse(res);
  }

  function toast(msg, ms = 1800) {
    const old = document.getElementById('xToastTmp');
    if (old) old.remove();
    const div = document.createElement('div');
    div.id = 'xToastTmp';
    div.textContent = msg;
    div.style.cssText = 'position:fixed;left:50%;top:24px;transform:translateX(-50%);z-index:99999;background:#1f2937;color:#fff;padding:10px 14px;border-radius:10px;box-shadow:0 6px 20px rgba(0,0,0,.2);font-size:13px;';
    document.body.appendChild(div);
    setTimeout(() => { if (div && div.parentNode) div.parentNode.removeChild(div); }, ms);
  }

  function esc(str) {
    return String(str ?? '').replace(/[&<>"']/g, (m) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[m]));
  }

  function fmtDate(d = new Date()) {
    const y = d.getFullYear();
    const m = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    return `${y}-${m}-${day}`;
  }

  const statDate = document.getElementById('statDate');
  const searchKeyword = document.getElementById('searchKeyword');
  const accountTbody = document.getElementById('accountTbody');
  const accountEmpty = document.getElementById('accountEmpty');
  const linksBox = document.getElementById('linksBox');
  const linksEmpty = document.getElementById('linksEmpty');
  const checkAll = document.getElementById('checkAll');
  const includeZero = document.getElementById('includeZero');

  let rowsCache = [];

  function fillForm(row) {
    document.getElementById('formId').value = row.id;
    document.getElementById('formAccount').value = row.account || '';
    document.getElementById('formRemark').value = row.remark || '';
  }

  function clearForm() {
    document.getElementById('formId').value = '';
    document.getElementById('formAccount').value = '';
    document.getElementById('formRemark').value = '';
  }

  function renderTable(rows) {
    rowsCache = rows || [];
    if (!rowsCache.length) {
      accountTbody.innerHTML = '';
      accountEmpty.style.display = '';
      return;
    }
    accountEmpty.style.display = 'none';

    accountTbody.innerHTML = rowsCache.map(r => `
      <tr>
        <td><input type="checkbox" class="row-check" value="${r.id}"></td>
        <td>${r.id}</td>
        <td>${esc(r.account)}</td>
        <td>${esc(r.remark)}</td>
        <td class="num">${Number(r.day_success || 0)}</td>
        <td>${esc(r.updated_at || '')}</td>
        <td>
          <button class="ghost btn-edit" data-id="${r.id}">编辑</button>
          <button class="danger btn-del" data-id="${r.id}">删除</button>
        </td>
      </tr>
    `).join('');

    accountTbody.querySelectorAll('.btn-edit').forEach(btn => {
      btn.addEventListener('click', () => {
        const id = Number(btn.dataset.id);
        const row = rowsCache.find(x => Number(x.id) === id);
        if (row) fillForm(row);
      });
    });

    accountTbody.querySelectorAll('.btn-del').forEach(btn => {
      btn.addEventListener('click', async () => {
        const id = Number(btn.dataset.id);
        if (!confirm('确认删除该账号？')) return;
        try {
          await apiPost('account_delete', { id });
          await loadAccounts();
        } catch (e) {
          alert('删除失败：' + (e.message || e));
        }
      });
    });
  }

  async function loadAccounts() {
    try {
      const date = statDate.value || fmtDate();
      const data = await apiGet('accounts', {
        keyword: searchKeyword.value.trim(),
        date,
        include_zero: includeZero.checked ? 1 : 0,
      });
      renderTable(data.rows || []);
      checkAll.checked = false;

      const sumDate = data.date || date;
      const sumUsers = Number(data.active_user_count || 0);
      const sumTotal = Number(data.total_success || 0);
      document.getElementById('sumDate').textContent = sumDate;
      document.getElementById('sumUsers').textContent = sumUsers;
      document.getElementById('sumTotal').textContent = sumTotal;
      document.getElementById('sumDateSide').textContent = sumDate;
      document.getElementById('sumUsersSide').textContent = sumUsers;
      document.getElementById('sumTotalSide').textContent = sumTotal;
    } catch (e) {
      alert('加载账号失败：' + (e.message || e));
    }
  }

  function getSelectedIds() {
    const ids = [];
    document.querySelectorAll('.row-check:checked').forEach(chk => ids.push(Number(chk.value)));
    return ids.filter(v => v > 0);
  }

  checkAll.addEventListener('change', () => {
    document.querySelectorAll('.row-check').forEach(chk => chk.checked = checkAll.checked);
  });

  document.getElementById('btnSearch').addEventListener('click', loadAccounts);
  document.getElementById('btnToday').addEventListener('click', () => {
    statDate.value = fmtDate();
    loadAccounts();
  });
  document.getElementById('btnBackfill').addEventListener('click', async () => {
    const date = statDate.value || fmtDate();
    if (!confirm(`确认补齐 ${date} 未建档账号？`)) return;
    try {
      const data = await apiPost('backfill_accounts', { date });
      alert(`补齐完成：新增 ${Number(data.inserted || 0)} 个账号`);
      await loadAccounts();
    } catch (e) {
      alert('补齐失败：' + (e.message || e));
    }
  });


  statDate.addEventListener('change', loadAccounts);
  includeZero.addEventListener('change', loadAccounts);
  document.getElementById('btnReset').addEventListener('click', () => {
    searchKeyword.value = '';
    statDate.value = fmtDate();
    includeZero.checked = false;
    loadAccounts();
  });

  document.getElementById('btnSave').addEventListener('click', async () => {
    const id = Number(document.getElementById('formId').value || 0);
    const account = document.getElementById('formAccount').value.trim();
    const remark = document.getElementById('formRemark').value.trim();
    if (!account) {
      alert('账号不能为空');
      return;
    }
    try {
      await apiPost('account_save', { id, account, remark });
      clearForm();
      await loadAccounts();
    } catch (e) {
      alert('保存失败：' + (e.message || e));
    }
  });

  document.getElementById('btnClear').addEventListener('click', clearForm);

  document.getElementById('btnBatchSave').addEventListener('click', async () => {
    const accountsText = document.getElementById('batchAccounts').value || '';
    const remark = document.getElementById('batchRemark').value.trim();
    if (!accountsText.trim()) {
      alert('请先输入账号（每行一个）');
      return;
    }

    try {
      const data = await apiPost('account_batch_save', { accounts_text: accountsText, remark });
      alert(`批量添加成功：共处理 ${Number(data.count || 0)} 个账号`);
      document.getElementById('batchAccounts').value = '';
      await loadAccounts();
    } catch (e) {
      alert('批量添加失败：' + (e.message || e));
    }
  });

  document.getElementById('btnBatchClear').addEventListener('click', () => {
    document.getElementById('batchAccounts').value = '';
  });



  document.getElementById('btnGenLinks').addEventListener('click', async () => {
    const ids = getSelectedIds();
    if (!ids.length) {
      alert('请至少选择一个账号');
      return;
    }
    try {
      const data = await apiPost('generate_links', { account_ids: ids });
      const links = data.links || [];
      if (!links.length) {
        linksBox.innerHTML = '';
        linksEmpty.style.display = '';
        return;
      }
      linksEmpty.style.display = 'none';
      linksBox.innerHTML = links.map(x => `
        <div class="link-item">
          <div><b>备注：</b>${esc(x.remark)}</div>
          <div><b>账号ID：</b>${esc((x.account_ids || []).join(','))}</div>
          <div><a href="${esc(x.url)}" target="_blank">${esc(x.url)}</a></div>
        </div>
      `).join('');
    } catch (e) {
      alert('生成链接失败：' + (e.message || e));
    }
  });

  async function loadUpdateConfig() {
    const status = document.getElementById('updStatus');
    try {
      const data = await apiGet('app_update_admin_get');
      document.getElementById('updVersion').value = data.latest_version || '';
      document.getElementById('updForce').checked = Number(data.force_update || 0) === 1;
      document.getElementById('updApkUrl').value = data.apk_url || '';
      document.getElementById('updNotes').value = data.release_notes || '';
      status.textContent = `状态：已加载（更新时间 ${data.updated_at || '-' }）`;
    } catch (e) {
      status.textContent = '状态：加载失败 - ' + (e.message || e);
    }
  }

  document.getElementById('btnUpdReload').addEventListener('click', loadUpdateConfig);

  document.getElementById('btnUpdSave').addEventListener('click', async () => {
    const btn = document.getElementById('btnUpdSave');
    const status = document.getElementById('updStatus');
    const latest_version = document.getElementById('updVersion').value.trim();
    const force_update = document.getElementById('updForce').checked ? 1 : 0;
    const apk_url = document.getElementById('updApkUrl').value.trim();
    const release_notes = document.getElementById('updNotes').value.trim();

    if (!latest_version) {
      toast('请填写最新版本号');
      return;
    }
    if (!apk_url) {
      toast('请填写APK下载地址或先上传APK');
      return;
    }

    btn.disabled = true;
    const oldText = btn.textContent;
    btn.textContent = '保存中...';
    try {
      await apiPost('app_update_admin_set', { latest_version, force_update, apk_url, release_notes });
      toast('更新配置已保存');
      status.textContent = '状态：保存成功';
      await loadUpdateConfig();
    } catch (e) {
      status.textContent = '状态：保存失败 - ' + (e.message || e);
      toast('保存失败：' + (e.message || e), 2600);
    } finally {
      btn.disabled = false;
      btn.textContent = oldText;
    }
  });

  document.getElementById('btnUpdUpload').addEventListener('click', async () => {
    const btn = document.getElementById('btnUpdUpload');
    const status = document.getElementById('updStatus');
    const input = document.getElementById('updApkFile');
    const file = input.files && input.files[0];
    if (!file) {
      toast('请先选择APK文件');
      return;
    }
    const fd = new FormData();
    fd.append('apk', file);

    btn.disabled = true;
    const oldText = btn.textContent;
    btn.textContent = '上传中...';
    status.textContent = `状态：正在上传 ${file.name} ...`;

    try {
      const data = await apiPostForm('app_update_upload_apk', fd);
      document.getElementById('updApkUrl').value = data.latest_url || data.apk_url || '';
      status.textContent = `状态：上传完成，已填充固定下载地址（${data.file_name || ''}）`;
      toast('APK上传成功，下载地址已自动填充');
    } catch (e) {
      status.textContent = '状态：上传失败 - ' + (e.message || e);
      toast('APK上传失败：' + (e.message || e), 2600);
    } finally {
      btn.disabled = false;
      btn.textContent = oldText;
    }
  });

  if (!statDate.value) statDate.value = fmtDate();
  loadAccounts();
  loadUpdateConfig();

  setInterval(() => {
    loadAccounts();
  }, 5000);
</script>
</body>
</html>
