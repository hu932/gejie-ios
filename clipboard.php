<?php
session_start();
header('Content-Type: text/html; charset=utf-8');

$storageFile = __DIR__ . DIRECTORY_SEPARATOR . 'clipboard_data.txt';
$maxLength = 20000;

function loadClipboard(string $file): array {
    if (!is_file($file)) {
        return ['text' => '', 'updated_at' => null];
    }
    $raw = file_get_contents($file);
    if ($raw === false || $raw === '') {
        return ['text' => '', 'updated_at' => null];
    }
    $data = json_decode($raw, true);
    if (!is_array($data)) {
        return ['text' => (string)$raw, 'updated_at' => null];
    }
    return [
        'text' => (string)($data['text'] ?? ''),
        'updated_at' => $data['updated_at'] ?? null,
    ];
}

function saveClipboard(string $file, string $text): void {
    $payload = json_encode([
        'text' => $text,
        'updated_at' => date('Y-m-d H:i:s'),
    ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    file_put_contents($file, $payload, LOCK_EX);
}

if (isset($_GET['action']) && $_GET['action'] === 'raw') {
    $data = loadClipboard($storageFile);
    header('Content-Type: text/plain; charset=utf-8');
    echo $data['text'];
    exit;
}

if (isset($_GET['action']) && $_GET['action'] === 'json') {
    $data = loadClipboard($storageFile);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode([
        'ok' => true,
        'text' => $data['text'],
        'updated_at' => $data['updated_at'],
        'length' => mb_strlen($data['text'], 'UTF-8'),
    ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

$status = '';
$clipboard = loadClipboard($storageFile);
$text = $clipboard['text'];

if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'POST') {
    $incoming = (string)($_POST['content'] ?? '');
    $incoming = str_replace(["\r\n", "\r"], "\n", $incoming);
    if (mb_strlen($incoming, 'UTF-8') > $maxLength) {
        $status = '内容太长，请缩短后再保存。';
    } else {
        saveClipboard($storageFile, $incoming);
        $clipboard = loadClipboard($storageFile);
        $text = $clipboard['text'];
        $status = '已保存，手机端刷新后即可复制。';
    }
}

$displayText = htmlspecialchars($text, ENT_QUOTES, 'UTF-8');
$length = mb_strlen($text, 'UTF-8');
$lines = $text === '' ? 0 : substr_count($text, "\n") + 1;
$updatedAt = $clipboard['updated_at'] ?? '-';
?>
<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>在线共享粘贴板</title>
  <style>
    :root {
      --bg: #0f172a;
      --bg2: #111827;
      --card: rgba(17, 24, 39, .72);
      --card-border: rgba(255,255,255,.08);
      --text: #e5e7eb;
      --muted: #94a3b8;
      --accent: #38bdf8;
      --accent2: #60a5fa;
      --success: #22c55e;
      --shadow: 0 24px 70px rgba(0,0,0,.32);
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      min-height: 100vh;
      color: var(--text);
      font-family: -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Helvetica,Arial,"PingFang SC","Microsoft YaHei",sans-serif;
      background:
        radial-gradient(circle at top left, rgba(56, 189, 248, .18), transparent 28%),
        radial-gradient(circle at top right, rgba(96, 165, 250, .16), transparent 26%),
        linear-gradient(180deg, var(--bg) 0%, var(--bg2) 100%);
    }
    .wrap {
      width: min(1120px, calc(100vw - 28px));
      margin: 0 auto;
      padding: 18px 0 28px;
    }
    .hero {
      background: linear-gradient(135deg, rgba(56,189,248,.15), rgba(96,165,250,.10));
      border: 1px solid rgba(255,255,255,.08);
      border-radius: 28px;
      padding: 22px;
      box-shadow: var(--shadow);
      backdrop-filter: blur(16px);
    }
    .hero-top { display:flex; justify-content:space-between; gap: 14px; align-items:flex-start; flex-wrap: wrap; }
    .title { margin: 0; font-size: clamp(24px, 3vw, 36px); letter-spacing: .01em; }
    .subtitle { margin: 10px 0 0; color: var(--muted); line-height: 1.7; max-width: 760px; }
    .chip-row { display:flex; gap: 10px; flex-wrap: wrap; margin-top: 16px; }
    .chip {
      display:inline-flex; align-items:center; gap: 8px;
      padding: 10px 14px; border-radius: 999px;
      background: rgba(255,255,255,.06); border: 1px solid rgba(255,255,255,.08);
      color: var(--text); font-size: 13px; font-weight: 600;
    }
    .grid {
      margin-top: 18px;
      display: grid;
      grid-template-columns: 1fr 360px;
      gap: 18px;
    }
    .card {
      background: var(--card);
      border: 1px solid var(--card-border);
      border-radius: 24px;
      box-shadow: var(--shadow);
      backdrop-filter: blur(16px);
    }
    .panel { padding: 18px; }
    .panel-title { margin: 0 0 14px; font-size: 16px; font-weight: 700; }
    textarea {
      width: 100%;
      min-height: 430px;
      resize: vertical;
      border: 1px solid rgba(148,163,184,.22);
      border-radius: 18px;
      padding: 16px;
      outline: none;
      background: rgba(15, 23, 42, .35);
      color: #f8fafc;
      font-size: 16px;
      line-height: 1.65;
      font-family: inherit;
    }
    textarea:focus { border-color: rgba(56,189,248,.7); box-shadow: 0 0 0 4px rgba(56,189,248,.12); }
    .actions { display:flex; gap: 10px; flex-wrap: wrap; margin-top: 14px; }
    button, a.btn {
      appearance: none;
      border: 0;
      height: 46px;
      padding: 0 16px;
      border-radius: 14px;
      font-size: 14px;
      font-weight: 700;
      cursor: pointer;
      text-decoration: none;
      display:inline-flex;
      align-items:center;
      justify-content:center;
    }
    .primary { background: linear-gradient(135deg, var(--accent) 0%, var(--accent2) 100%); color: #fff; }
    .ghost { background: rgba(255,255,255,.06); color: var(--text); border: 1px solid rgba(255,255,255,.10); }
    .stats { display:grid; gap: 12px; }
    .stat {
      padding: 14px 16px;
      border-radius: 18px;
      background: rgba(255,255,255,.05);
      border: 1px solid rgba(255,255,255,.08);
    }
    .stat .k { color: var(--muted); font-size: 12px; margin-bottom: 6px; }
    .stat .v { font-size: 18px; font-weight: 800; }
    .copybox {
      margin-top: 12px;
      border-radius: 18px;
      border: 1px solid rgba(255,255,255,.08);
      background: rgba(15,23,42,.34);
      padding: 14px;
    }
    .copybox textarea { min-height: 300px; margin: 0; }
    .toast {
      position: fixed;
      left: 50%;
      bottom: 22px;
      transform: translateX(-50%);
      background: rgba(15,23,42,.88);
      border: 1px solid rgba(255,255,255,.10);
      color: #fff;
      padding: 12px 16px;
      border-radius: 14px;
      box-shadow: var(--shadow);
      z-index: 9999;
      display: none;
      max-width: calc(100vw - 30px);
      text-align: center;
    }
    @media (max-width: 920px) {
      .grid { grid-template-columns: 1fr; }
      textarea { min-height: 300px; }
    }
  </style>
</head>
<body>
  <div class="wrap">
    <section class="hero">
      <div class="hero-top">
        <div>
          <h1 class="title">在线共享粘贴板</h1>
          <p class="subtitle">电脑端粘贴文字并保存，手机打开后即可直接复制。适合临时传文字、验证码、地址、说明内容。</p>
          <div class="chip-row">
            <span class="chip">最后更新：<?= htmlspecialchars((string)$updatedAt, ENT_QUOTES, 'UTF-8') ?></span>
            <span class="chip">字符数：<?= (int)$length ?></span>
            <span class="chip">行数：<?= (int)$lines ?></span>
          </div>
        </div>
        <div class="actions">
          <a class="btn ghost" href="?action=raw" target="_blank">查看纯文本</a>
          <button type="button" class="primary" id="btnCopyAll">复制全部</button>
        </div>
      </div>
    </section>

    <div class="grid">
      <section class="card panel">
        <h2 class="panel-title">编辑内容</h2>
        <form method="post" action="clipboard.php" id="pasteForm">
          <textarea id="content" name="content" placeholder="把你想共享的文字粘贴到这里..."><?= $displayText ?></textarea>
          <div class="actions">
            <button type="submit" class="primary">保存内容</button>
            <button type="button" class="ghost" id="btnClear">清空</button>
            <button type="button" class="ghost" id="btnRefresh">刷新内容</button>
          </div>
        </form>
      </section>

      <aside class="card panel">
        <h2 class="panel-title">手机端复制</h2>
        <div class="stats">
          <div class="stat"><div class="k">使用方式</div><div class="v">手机打开此页面，长按或点按钮复制。</div></div>
          <div class="stat"><div class="k">共享链接</div><div class="v" style="word-break:break-all; font-size:14px; font-weight:700;"><?=$_SERVER['HTTP_HOST'] ?? 'localhost'?>/clipboard.php</div></div>
          <div class="stat"><div class="k">状态</div><div class="v"><?= $text === '' ? '暂无内容' : '内容已更新' ?></div></div>
        </div>
        <div class="copybox">
          <textarea id="preview" readonly><?= $displayText ?></textarea>
        </div>
        <div class="actions">
          <button type="button" class="primary" id="btnCopyPreview">复制当前内容</button>
        </div>
      </aside>
    </div>
  </div>

  <div class="toast" id="toast"></div>

  <script>
    const content = document.getElementById('content');
    const preview = document.getElementById('preview');
    const toast = document.getElementById('toast');

    function showToast(msg) {
      toast.textContent = msg;
      toast.style.display = 'block';
      clearTimeout(window.__toastTimer);
      window.__toastTimer = setTimeout(() => { toast.style.display = 'none'; }, 1800);
    }

    async function copyText(text) {
      try {
        await navigator.clipboard.writeText(text);
        showToast('已复制到剪贴板');
      } catch (e) {
        const ta = document.createElement('textarea');
        ta.value = text;
        document.body.appendChild(ta);
        ta.select();
        document.execCommand('copy');
        document.body.removeChild(ta);
        showToast('已复制到剪贴板');
      }
    }

    document.getElementById('btnCopyAll').addEventListener('click', () => copyText(content.value || ''));
    document.getElementById('btnCopyPreview').addEventListener('click', () => copyText(preview.value || ''));
    document.getElementById('btnClear').addEventListener('click', () => {
      content.value = '';
      preview.value = '';
      showToast('已清空，点击保存后生效');
    });
    document.getElementById('btnRefresh').addEventListener('click', () => location.reload());

    content.addEventListener('input', () => {
      preview.value = content.value;
    });

    document.getElementById('pasteForm').addEventListener('submit', () => {
      showToast('正在保存...');
    });
  </script>
</body>
</html>
