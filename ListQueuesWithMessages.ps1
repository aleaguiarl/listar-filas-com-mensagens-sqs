$startTime = $(Get-Date)
$queues = (aws sqs list-queues | ConvertFrom-Json).QueueUrls
$queueData = for ($i = 0; $i -lt $queues.Count; $i++) {
    [PSCustomObject]@{
        Index = $i
        Url   = $queues[$i]
        TotalQueues = $queues.Count
    }
}

$total = $queues.Count
Write-Output "TOTAL DE FILAS: $total"

$queueData | ForEach-Object -Parallel {
    $url = $_.Url
    $queueName = $url -replace "https://sqs.sa-east-1.amazonaws.com/381492245517/", ""
    $index = $_.Index
    $totalQueues = $_.TotalQueues

    $msgCount = aws sqs get-queue-attributes --queue-url $url --attribute-names ApproximateNumberOfMessages --query "Attributes.ApproximateNumberOfMessages" --output text
    if ($msgCount -gt 0) {
        Write-Host "$index. $queueName ($msgCount mensagens)" -ForegroundColor Green
    } else {
        Write-Host "[------------VAZIA------------]$index. $queueName"
    }

    $currentProgress = [Math]::Round((($index + 1) * 100)/$totalQueues, 2) 
    Write-Progress -Activity "Search in Progress" -Status "$currentProgress% Complete:" -PercentComplete $currentProgress
} -ThrottleLimit 10

$elapsedTime = $(Get-Date) - $startTime
$totalTime = "{0:HH:mm:ss}" -f ([datetime]$elapsedTime.Ticks)
Write-Output "Tempo total de processamento: $totalTime"