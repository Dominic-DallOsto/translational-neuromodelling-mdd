function A_new = reorder_A_matrix(A)
	% Order:
	% Left:
	%	- Glasser: V1 -> p24
	%	- Fischl: thalamus -> choroid plexus
	% Brainstem
	% Right:
	%	- Fischl: choroid plexus -> thalamus
	%	- Glasser: p24 -> V1
	new_order = [1:180 361:368 377 376:-1:369 360:-1:181];
	A_new = A(new_order, new_order);