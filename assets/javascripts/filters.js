function add_filter() {
    select = $('add_filter_select');
    field = select.value
    Element.show('tr_' +  field);
    check_box = $('cb_' + field);
    check_box.checked = true;
    toggle_filter(field);
    select.selectedIndex = 0;

    for (i=0; i<select.options.length; i++) {
        if (select.options[i].value == field) {
            select.options[i].disabled = true;
        }
    }
}

function toggle_filter(field) {
    check_box = $('cb_' + field);

    if (check_box.checked) {
        Element.show("operators_" + field);
        Form.Element.enable("operators_" + field);
        toggle_operator(field);
    } else {
        Element.hide("operators_" + field);
        Form.Element.disable("operators_" + field);
        enableValues(field, []);
  }
}

function enableValues(field, indexes) {
  var f = $$(".values_" + field);
  for(var i=0;i<f.length;i++) {
    if (indexes.include(i)) {
      Form.Element.enable(f[i]);
      f[i].up('span').show();
    } else {
      f[i].value = '';
      Form.Element.disable(f[i]);
      f[i].up('span').hide();
    }
  }
  if (indexes.length > 0) {
    Element.show("div_values_" + field);
  } else {
    Element.hide("div_values_" + field);
  }
}

function toggle_operator(field) {
  operator = $("operators_" + field);
  switch (operator.value) {
    case "!*":
    case "*":
    case "t":
    case "w":
    case "o":
    case "c":
      enableValues(field, []);
      break;
    case "><":
      enableValues(field, [0,1]);
      break;
    case "<t+":
    case ">t+":
    case "t+":
    case ">t-":
    case "<t-":
    case "t-":
      enableValues(field, [2]);
      break;
    default:
      enableValues(field, [0]);
      break;
  }
}

function toggle_multi_select(el) {
  var select = $(el);
  if (select.multiple == true) {
    select.multiple = false;
  } else {
    select.multiple = true;
  }
}