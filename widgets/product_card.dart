import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding : EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        margin: EdgeInsets.only(top:10, bottom: 10),
        width: double.infinity ,
        height: 80,
        decoration: _cardBorders(),
        child: Stack(
          children: [
            _ProductDetails(),

          ],
        ),
      ),
    );
  }

 BoxDecoration _cardBorders() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(25),
    boxShadow: const [
      BoxShadow(
        color: Colors.black12,
        offset: Offset(0,7),
        blurRadius: 5
      )
    ]
 );

}


class _ProductDetails extends StatelessWidget {
  const _ProductDetails({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        width: double.infinity,
        height: 80,
        decoration: _buildBoxDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SKU: 123345',
                 style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                 maxLines: 1,
                 overflow: TextOverflow.ellipsis,
            ),
            FittedBox(
              fit: BoxFit.contain,
              child: Padding(
                child: Text('Description: 1233',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                padding: EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
            FittedBox(
              fit: BoxFit.contain,
              child: Padding(
                child: Text('Price: 1,234.1  Shelf: 01  Qty:10  Qty.Upd: 20',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                padding: EdgeInsets.symmetric(horizontal: 10),
              ),
            )
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() => BoxDecoration(
    color: Colors.indigo,
    borderRadius: BorderRadius.only( topLeft: Radius.circular(25),topRight: Radius.circular(25), bottomRight: Radius.circular(25), bottomLeft:Radius.circular(25) )
  );
}

