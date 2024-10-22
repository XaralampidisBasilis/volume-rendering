block.lod--;
block.size *= 0.5;
occumap_dimensions *= 2;
occumap_offset.y = (block.lod > 0) ? base_dimensions.y - 2 * occumap_dimensions.y : 0;
occumap_offset.z = (block.lod > 0) ? base_dimensions.z : 0;