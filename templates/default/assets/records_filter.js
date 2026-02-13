$(function() {

	// Build type filter dropdown
	var typeDropdown = $('<div class="dropdown"></div>');
	var typeBtn = $('<button class="form-control form-control-sm dropdown-toggle text-start" type="button" data-bs-toggle="dropdown" data-bs-auto-close="outside">Filter...</button>');
	var typeMenu = $('<div class="dropdown-menu"></div>');
	$.each(recordtypes, function(type, label) {
		typeMenu.append('<label class="dropdown-item"><input type="checkbox" class="form-check-input me-1" value="' + type + '"> ' + label + '</label>');
	});
	typeDropdown.append(typeBtn).append(typeMenu);
	$('#typeFilterCell').append(typeDropdown);

	var filterInputs = $('#records thead .filter-row input[data-filter]');
	var typeCheckboxes = typeMenu.find('input[type="checkbox"]');
	var clearBtn = $('#clearFilters');

	function applyFilters() {
		var filters = {};
		filterInputs.each(function() {
			var val = $(this).val().toLowerCase().trim();
			if (val) {
				filters[$(this).data('filter')] = val;
			}
		});

		var selectedTypes = [];
		typeCheckboxes.filter(':checked').each(function() {
			selectedTypes.push($(this).val());
		});

		var hasFilters = Object.keys(filters).length > 0 || selectedTypes.length > 0;
		clearBtn.toggleClass('d-none', !hasFilters);
		typeBtn.text(selectedTypes.length > 0 ? selectedTypes.length + ' selected' : 'Filter...');

		$('#records tbody tr').each(function() {
			var row = $(this);

			if (row.hasClass('new') || row.hasClass('edited') || row.hasClass('deleted')) {
				row.show();
				return;
			}

			if (!hasFilters) {
				row.show();
				return;
			}

			var visible = true;

			if (selectedTypes.length > 0) {
				var rowType = String(row.find('td.type').data('value') || row.find('td.type').text().trim());
				if (selectedTypes.indexOf(rowType) === -1) {
					visible = false;
				}
			}

			if (visible) {
				$.each(filters, function(column, filterValue) {
					var cell = row.find('td.' + column);
					var cellValue = '';
					if (cell.data('value') !== undefined && cell.data('value') !== null) {
						cellValue = String(cell.data('value'));
					} else {
						cellValue = cell.text().trim();
					}
					if (cellValue.toLowerCase().indexOf(filterValue) === -1) {
						visible = false;
						return false;
					}
				});
			}

			row.toggle(visible);
		});
	}

	filterInputs.on('input', applyFilters);
	typeCheckboxes.on('change', applyFilters);

	clearBtn.on('click', function() {
		filterInputs.val('');
		typeCheckboxes.prop('checked', false);
		applyFilters();
	});
});
