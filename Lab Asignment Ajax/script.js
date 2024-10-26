
const API_URL = "https://usmanlive.com/wp-json/api/stories";


function fetchStories() {
    $.get(API_URL, function(data) {
        let storiesList = $("#storiesList").empty();
        data.forEach(story => {
            storiesList.append(`
                <div class="story">
                    <h3>${story.title}</h3>
                    <p>${story.content}</p>
                    <button class="edit-btn" data-id="${story.id}">Edit</button>
                    <button class="delete-btn" data-id="${story.id}">Delete</button>
                </div>
                <hr/>
            `);
        });
    });
}


function handleFormSubmit(event) {
    event.preventDefault();
    const title = $("#title").val();
    const content = $("#content").val();
    const id = $("#submitBtn").data("id");
    
    const storyData = { title, content };

    if (id) {
        $.ajax({
            url: `${API_URL}/${id}`,
            method: "PUT",
            data: storyData,
            success: function() {
                resetForm();
                fetchStories();
            }
        });
    } else {

        $.post(API_URL, storyData, function() {
            resetForm();
            fetchStories();
        });
    }
}


function deleteStory() {
    const id = $(this).data("id");
    $.ajax({
        url: `${API_URL}/${id}`,
        method: "DELETE",
        success: fetchStories
    });
}


function editStory() {
    const id = $(this).data("id");
    $.get(`${API_URL}/${id}`, function(data) {
        $("#title").val(data.title);
        $("#content").val(data.content);
        $("#submitBtn").data("id", data.id).text("Update Story");
    });
}

function resetForm() {
    $("#title").val("");
    $("#content").val("");
    $("#submitBtn").data("id", "").text("Create Story");
}


$(document).ready(function() {
    fetchStories();
    $("#storyForm").submit(handleFormSubmit);
    $("#storiesList").on("click", ".delete-btn", deleteStory);
    $("#storiesList").on("click", ".edit-btn", editStory);
});
