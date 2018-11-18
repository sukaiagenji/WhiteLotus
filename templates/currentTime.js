<script type="text/javascript">
function startTime() {
    var date = new Date();
    var h = date.getHours() > 12 ? date.getHours() - 12 : date.getHours();
	if (h == 0) { h = 12; }
    var m = date.getMinutes() < 10 ? "0" + date.getMinutes() : date.getMinutes();
    document.getElementById('time').innerHTML = h + ":" + m;
    t = setTimeout(function () {
        startTime()
    }, 500);
}
startTime();
</script>