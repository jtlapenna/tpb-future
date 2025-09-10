import { Body, Controller, Get, Param, Post, Res } from '@nestjs/common';
import { ProductSearchDto } from 'src/models/dto/product-search.dto';
import { ProductDto } from 'src/models/dto/product.dto';
import { ProductService } from './product.service';
import { Response } from 'express';

@Controller('apiv1/products')
export class ProductController {
  constructor(private readonly productService: ProductService) {}

  @Post('all')
  async getAll(@Body() search: ProductSearchDto): Promise<ProductDto[]> {
    return this.productService.findAll(search);
  }

  @Get('find/:id')
  async find(@Param('id') id: number): Promise<ProductDto> {
    const products = await this.productService.findOne(id);
    if (products.length === 1) {
      const p = products[0];
      return {
        ...p,
        tags: await this.productService.findTags(id),
      };
    }

    return null;
  }

  @Get('findBySku/:sku')
  async findBySku(
    @Param('sku') sku: string,
    @Res() res: Response,
  ): Promise<string> {
    const products = await this.productService.findBySku(sku);

    if (products.length !== 0) {
      res.redirect(products[0].image_url);
    }
    return '';
  }

  @Post('onsales')
  async onSales(@Body() search: ProductSearchDto): Promise<ProductDto[]> {
    return this.productService.findOnSales(search);
  }

  @Post('featuredProducts')
  async featuredProducts(
    @Body() search: ProductSearchDto,
  ): Promise<ProductDto[]> {
    return this.productService.featuredProducts(search);
  }

  @Get('highlights/:storeId')
  async highlights(@Param('storeId') storeId: number): Promise<ProductDto[]> {
    return this.productService.highlights(storeId);
  }
}
