/**
 * Migración de Prototype/Chosen a jQuery + Select2.
 * Reemplaza $$, Event.observe, Effect.Opacity, y Chosen usage.
 * Mantiene nombres de funciones y expone en window.
 */

// Activa los selectores chosen
var activaSelectoresChosen = function() {
  // Sustituido por Select2 con jQuery
  window.jQuery && window.jQuery('.chosen_select').each(function() {
    var $el = window.jQuery(this);
    if ($el.hasClass('select2-hidden-accessible')) return; // ya inicializado
    var placeholder = $el.attr('data-placeholder') || 'Ningún elemento seleccionado...';
    $el.attr('data-placeholder', placeholder);
    $el.removeClass('chosen_select');
    $el.select2({
      width: '100%',
      allowClear: true,
      placeholder: placeholder,
      language: 'es'
    });
  });
};
// Expose globally for inline calls in layout
window.activaSelectoresChosen = activaSelectoresChosen;

// Cambia el logo de background
var changeBackground = function() {
  var logoUrl = window.TPV_LOGO || '';
  if (window.jQuery) {
    window.jQuery('#logo').css('background-image', 'url(' + logoUrl + ')');
  } else {
    var el = document.getElementById('logo');
    if (el) el.style.backgroundImage = 'url(' + logoUrl + ')';
  }
};
window.changeBackground = changeBackground;

function stopRKey(evt) {
  var evt = (evt) ? evt : ((event) ? event : null);
  var node = (evt.target) ? evt.target : ((evt.srcElement) ? evt.srcElement : null);
  if ((evt.keyCode == 13) && (node.id=="formulario_campo_item_codigo"))  {
    return false;
  }
};

document.onkeypress = stopRKey;

document.addEventListener('turbo:load', function() {
  setTimeout(function() { fadeout(); }, 3500);
  setTimeout(function() {
    if (window.jQuery) {
      window.jQuery('#mensaje').hide();
    } else {
      var el = document.getElementById('mensaje');
      if (el) el.style.display = 'none';
    }
  }, 4800);
});
function fadeout(){
  if (window.jQuery) {
    window.jQuery('#mensaje').fadeTo(1500, 0.0);
  } else {
    var el = document.getElementById('mensaje');
    if (el) el.style.opacity = '0';
  }
};
window.fadeout = fadeout;
