var dataContainer = document.getElementById("simple-api-content");
var btn = document.getElementById("btn");

btn.addEventListener("click", function () {
    var myRequest = new XMLHttpRequest();
    myRequest.open('GET', '${api_url}');
    myRequest.onload = function() {
        var apiData = myRequest.responseText;
        renderContent(apiData)
    };
    myRequest.send();
});

function renderContent(data) {
    dataContainer.insertAdjacentText('beforeend', data);
}