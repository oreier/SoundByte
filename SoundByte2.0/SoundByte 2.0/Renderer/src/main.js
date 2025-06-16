/*
Main entry point for program, loads in json from parser,
renders the music on the screen, and logs the target pitches
*/

import * as Renderer from './renderer.js';

//grab the data and create the song object out of it
const fileInput = document.getElementById("fileInput");
fileInput.addEventListener("change", render, false);

function render() { //called when the file changes
    const selectedFile = fileInput.files[0];

    const reader = new FileReader();
    reader.onload = function(e) {
        const fileContent = e.target.result; //grab the content
        var data = JSON.parse(fileContent); //turn it into an object
        var song = data.song; //grab the song object

        Renderer.renderSong(song); 

        console.log(Renderer.pitches); //the output to be used by the grader, not sure how to best output for the app to read yet        
    }

    reader.readAsText(selectedFile); //actually read the file, triggering onload()
}
