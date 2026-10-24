# Serves a folder on http://localhost for testing the app page in a browser.
param([string]$Root, [int]$Port = 8765)
$Root = (Resolve-Path $Root).Path
$l = [System.Net.HttpListener]::new()
$l.Prefixes.Add("http://localhost:$Port/")
$l.Start()
Write-Host "Serving $Root on http://localhost:$Port/"
while ($l.IsListening) {
    $ctx = $l.GetContext()
    $path = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath.TrimStart('/'))
    if (-not $path) { $path = "index.html" }
    $file = Join-Path $Root $path
    if (Test-Path $file -PathType Leaf) {
        $bytes = [IO.File]::ReadAllBytes($file)
        $types = @{ ".html" = "text/html; charset=utf-8"; ".js" = "text/javascript"; ".webmanifest" = "application/manifest+json"; ".png" = "image/png"; ".json" = "application/json" }
        $ext = [IO.Path]::GetExtension($file)
        $ctx.Response.ContentType = if ($types[$ext]) { $types[$ext] } else { "application/octet-stream" }
        $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else { $ctx.Response.StatusCode = 404 }
    $ctx.Response.Close()
}
