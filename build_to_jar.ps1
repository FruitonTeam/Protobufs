$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8';

$JAR_NAME ='protobufs.jar';
$PROTOBUF_JAR_URL='http://central.maven.org/maven2/com/google/protobuf/protobuf-java/3.5.1/protobuf-java-3.5.1.jar';

$DIR = (pwd).path;

if (Test-Path protobuf_build_tmp_dir) {
    Remove-Item -Force -Recurse protobuf_build_tmp_dir;
}
mkdir protobuf_build_tmp_dir;

Write-Output 'Creating java files...';

protoc --java_out=protobuf_build_tmp_dir *.proto > $null;

cd protobuf_build_tmp_dir;
Get-Childitem -Path . -Recurse -File -Include *.java | Select-Object -ExpandProperty FullName | Resolve-Path -Relative | % { $_ -replace "\\","/" } | % { $_ -replace "\./","" } | % { $_ -replace "(.*)",'"${1}' } > sources.txt;
Get-Content .\sources.txt | Foreach-Object {$_ -replace "\xEF\xBB\xBF", ""} | Set-Content .\sources1.txt;

Write-Output 'Downloading protobuf-java.jar...';

$client = new-object System.Net.WebClient;
#$client.Headers.add('User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:23.0) Gecko/20100101 Firefox/23.0');
$client.DownloadFile($PROTOBUF_JAR_URL, "$($DIR)\protobuf_build_tmp_dir\protobuf-java-3.5.1.jar");

Write-Output 'Compiling sources...';

mkdir build;
javac '@sources1.txt' -d build -classpath protobuf-java-3.5.1.jar;

Write-Output 'Building jar...';

jar cf "$($DIR)\$($JAR_NAME)" -C build . > $null;

cd ..;

Remove-Item -Force -Recurse protobuf_build_tmp_dir;
