# Servidor HTTP Local para Sistema de Oficios
# Porta padrao: 8080

$port = 8080
$path = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   SISTEMA DE OFICIOS - SCFC" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Iniciando servidor local..." -ForegroundColor Yellow
Write-Host ""

# Verificar se a porta esta em uso
$portInUse = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
if ($portInUse) {
    Write-Host "AVISO: Porta $port ja esta em uso. Tentando porta 8081..." -ForegroundColor Yellow
    $port = 8081
}

# Criar listener HTTP
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Prefixes.Add("http://127.0.0.1:$port/")

try {
    $listener.Start()
    Write-Host "Servidor iniciado com sucesso!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Acesse o sistema em:" -ForegroundColor White
    Write-Host "  http://localhost:$port" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Pressione Ctrl+C para encerrar o servidor" -ForegroundColor Gray
    Write-Host ""
    
    # Abrir navegador automaticamente
    Start-Process "http://localhost:$port"
    
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        $localPath = $request.Url.LocalPath
        if ($localPath -eq "/") {
            $localPath = "/sistema_oficios_v2.html"
        }
        
        $filePath = Join-Path $path $localPath.TrimStart("/")
        
        if (Test-Path $filePath -PathType Leaf) {
            $content = [System.IO.File]::ReadAllBytes($filePath)
            
            # Definir Content-Type
            $extension = [System.IO.Path]::GetExtension($filePath).ToLower()
            $contentType = switch ($extension) {
                ".html" { "text/html; charset=utf-8" }
                ".css"  { "text/css; charset=utf-8" }
                ".js"   { "application/javascript; charset=utf-8" }
                ".json" { "application/json; charset=utf-8" }
                ".png"  { "image/png" }
                ".jpg"  { "image/jpeg" }
                ".jpeg" { "image/jpeg" }
                ".gif"  { "image/gif" }
                ".svg"  { "image/svg+xml" }
                ".ico"  { "image/x-icon" }
                default { "application/octet-stream" }
            }
            
            $response.ContentType = $contentType
            $response.ContentLength64 = $content.Length
            $response.OutputStream.Write($content, 0, $content.Length)
            
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $($request.HttpMethod) $localPath - 200 OK" -ForegroundColor Green
        }
        else {
            $response.StatusCode = 404
            $errorMsg = [System.Text.Encoding]::UTF8.GetBytes("<html><body><h1>404 - Arquivo nao encontrado</h1></body></html>")
            $response.ContentType = "text/html; charset=utf-8"
            $response.OutputStream.Write($errorMsg, 0, $errorMsg.Length)
            
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $($request.HttpMethod) $localPath - 404 Not Found" -ForegroundColor Red
        }
        
        $response.Close()
    }
}
catch {
    Write-Host "Erro: $_" -ForegroundColor Red
}
finally {
    $listener.Stop()
    Write-Host ""
    Write-Host "Servidor encerrado." -ForegroundColor Yellow
}
