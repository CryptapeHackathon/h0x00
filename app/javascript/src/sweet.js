import Swal from 'sweetalert2';

$(document).ready(()=> {
  let submitOrderButton = $("#submit-order-button");

  submitOrderButton.click(() => {
    Swal.queue([{
      position: 'center',
      type: 'success',
      // title: '订单提交成功！',
      html: "<p style='font-size: 1rem;'>订单提交成功！</p>",
      showConfirmButton: false,
      timer: 3000,
      heightAuto: false,
      width: "15.75rem",
      imageHeight: 40
    }])
  })
});
