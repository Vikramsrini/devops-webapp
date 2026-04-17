console.log('App loaded successfully');

document.addEventListener('DOMContentLoaded', function() {
    const button = document.querySelector('button');
    if (button) {
        button.addEventListener('click', function() {
            alert('Button clicked!');
        });
    }
});
