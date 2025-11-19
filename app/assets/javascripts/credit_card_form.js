// Get URL parameter from address bar
const getURLParameter = (param) => {
  const params = new URLSearchParams(window.location.search);
  return params.get(param);
};

$(document).ready(() => {

  /** -------------------------------
   *  Show Error Message
   * -------------------------------*/
  const showError = (message) => {
    if ($("#flash-messages").length < 1) {
      $('div.container.main div:first').prepend("<div id='flash-messages'></div>");
    }

    $("#flash-messages").html(
      `<div class="alert alert-warning">
         <a class="close" data-dismiss="alert">×</a>
         <div id="flash_alert">${message}</div>
       </div>`
    );

    $('.alert').delay(5000).fadeOut(3000);
    return false;
  };


  /** -------------------------------
   *  Stripe Response Handler
   * -------------------------------*/
  const stripeResponseHandler = (status, response) => {
    const $form = $('.cc_form');

    if (response.error) {
      console.log(response.error.message);
      showError(response.error.message);
      $form.find("input[type=submit]").prop("disabled", false);
    } else {
      const token = response.id;

      $form.append(
        $('<input type="hidden" name="payment[token]" />').val(token)
      );

      // Remove sensitive fields before submit
      $("[data-stripe=number]").remove();
      $("[data-stripe=cvv]").remove();
      $("[data-stripe=exp-year]").remove();
      $("[data-stripe=exp-month]").remove();
      $("[data-stripe=label]").remove();

      $form.get(0).submit();
    }
    return false;
  };


  /** -------------------------------
   *  Submit Handler (Stripe Token)
   * -------------------------------*/
  const submitHandler = (event) => {
    event.preventDefault();

    const $form = $(event.target);
    $form.find("input[type=submit]").prop("disabled", true);

    if (typeof Stripe !== 'undefined') {
      Stripe.card.createToken($form, stripeResponseHandler);
    } else {
      showError("Failed to load credit card processing functionality. Please reload the page.");
    }

    return false;
  };

  $(".cc_form").on("submit", submitHandler);


  /** -------------------------------
   *  Handle Plan Change
   * -------------------------------*/
  const handlePlanChange = (planType, formSelector) => {
    const $form = $(formSelector);

    if (!planType) {
      planType = $('#tenant_plan').val();
    }

    if (planType === 'premium') {
      // Show & require Stripe fields
      $('[data-stripe]').prop('required', true).show();

      $form.off('submit').on('submit', submitHandler);
    } else {
      // Hide Stripe fields
      $('[data-stripe]').hide().removeAttr('required');
      $form.off('submit');
    }
  };


  /** -------------------------------
   *  Trigger on Plan Change
   * -------------------------------*/
  $("#tenant_plan").on('change', function () {
    handlePlanChange($(this).val(), ".cc_form");
  });

  // Run once on load (URL param support)
  handlePlanChange(getURLParameter('plan'), ".cc_form");

});