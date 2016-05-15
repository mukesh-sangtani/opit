// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require manager_js/jquery.min
//= require manager_js/bootstrap.min
//= require manager_js/pixel-admin.min
//= require manager_js/jquery.alerts
//= require jquery_ujs


// require turbolinks

function get_list(){
	$.get($("#search_form").attr("action"), $("#search_form").serialize(), null, "script");
    return false;
}

$(function() {
  /* Pagination, search and sort functions */
  	$("body").on("click","#search_form_submit", function() {
      $("#js_page").val(1);
      get_list();
    });

    $("body").on("submit","#search_form", function() {
  		$("#js_page").val(1);
  		get_list();
      return false;
  	});

    $("body").on("click",".js_column", function(e) {
      $("#js_page").val(1);
      $("#js_sort").val($(this).attr("sort"));
      $("#js_direction").val($(this).attr("direction"));
      get_list();
    });

  	$("body").on("click","ul.pagination li a", function(e) {
  		e.preventDefault();
  		$("#js_page").val($(this).attr("page_id"));
  		get_list();
  	});

  	$("body").on("click",".pagination-per-page a", function() {
  		$("#js_limit").val($(this).attr("limit"));
  		$("#js_page").val(1);
	    get_list();
  	});

  /* Create, Edit, Delete and Change status */

  $("#create_form").on("ajax:beforeSend",function(){
    $(".js_error").remove();
  });
  $("#create_form").on("ajax:success",function(xhr,data){
    if(data.status){
      if(data.reload == undefined){
        $('#createModal').modal('hide');
        $("#js_success").attr("data-text",data.success_message)
        $("#js_success").trigger("click");
        get_list();
      }else{
        window.location.href = data.reload;
        return;
      }
    }else{
      $.each(data.error_messages, function( key, value ) {
        $("#create_form").find("#"+key).parents(".row:first").find(".js_error_container").html("<span class='js_error error'>"+value+"</span>");
      });
    }
  });

  $('#createModal').on('hidden.bs.modal', function () {
    $(this).find("input").val("");
    $(this).find("select").prop('selectedIndex',0);
  })

  $('#editModal').on('hidden.bs.modal', function () {
    $(this).data('bs.modal', null);
  })

  $("body").on("ajax:beforeSend","#edit_form",function(){
    $(".js_error").remove();
  });

  $("body").on("ajax:success","#edit_form",function(xhr,data){
    if(data.status){
      if(data.reload == undefined){
        $('#editModal').modal('hide');
        $("#js_success").attr("data-text",data.success_message)
        $("#js_success").trigger("click");
        get_list();
      }else{
        window.location.href = data.reload;
        return;
      }
    }else{
      $.each(data.error_messages, function( key, value ) {
          $("#edit_form").find("#"+key).parents(".row:first").find(".js_error_container").html("<span class='js_error error'>"+value+"</span>");
      });
    }
  });

  $("body").on("ajax:success",".js_delete_item",function(xhr,data){
    if(data.status){
      $("#js_success").attr("data-text",data.success_message)
      $("#js_success").trigger("click");
      get_list();
    }else{
      $("#js_error").attr("data-text",data.error_message)
      $("#js_error").trigger("click");
    }
  });

  $("body").on("ajax:success",".js_change_status",function(xhr,data){
    if(data.status){
      $("#js_success").attr("data-text",data.success_message)
      $("#js_success").trigger("click");
      get_list();
    }else{
      $("#js_error").attr("data-text",data.error_message)
      $("#js_error").trigger("click");
    }
  });


  $('#page-alerts-demo').on('click', 'button', function () {
    var $this = $(this);
    // Go to the top
    $('html,body').animate({ scrollTop: 0 }, 500);
    // Wait while page is scrolling
    setTimeout(function () {
      if ($this.hasClass('page-alerts-clear-btn')) {
        PixelAdmin.plugins.alerts.clear(
          true, // animate
          'pa_page_alerts_default' // namespace
        );
      } else {
        var options = {
          type: $this.attr('data-type'),
          namespace: 'pa_page_alerts_default'
        };
        if ($this.hasClass('auto-close-alert'))
          options['auto_close'] = 3; // seconds
        PixelAdmin.plugins.alerts.add($this.attr('data-text'), options);
      }
    }, 800);
  }); 

  $('.outline-switcher').switcher({
    on_state_content: '<span class="fa fa-check" style="font-size:11px;"></span>',
    off_state_content: '<span class="fa fa-times" style="font-size:11px;"></span>'
  });
});

function ajax_loader(){
  
}

function randString(n){
    if(!n){
      n = 5;
    }

    var text = '';
    var possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

    for(var i=0; i < n; i++){
        text += possible.charAt(Math.floor(Math.random() * possible.length));
    }
    return text;
}