$queues = (aws sqs list-queues | ConvertFrom-Json).QueueUrls

$queues | ForEach-Object -Parallel {
        
    $msgCount = aws sqs get-queue-attributes --queue-url $_ --attribute-names ApproximateNumberOfMessages --query "Attributes.ApproximateNumberOfMessages" --output text
    if ($msgCount -gt 0) {
        Write-Output "$_ ($msgCount mensagens)"
    } 

} -ThrottleLimit 20


