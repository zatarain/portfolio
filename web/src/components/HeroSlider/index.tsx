import 'react-responsive-carousel/lib/styles/carousel.min.css';
import { Carousel } from 'react-responsive-carousel';

interface Properties {
	images: object
}

const HeroSlider = ({ images }: Properties) => {
	return (
		<div>
			<Carousel>
				{
					Object.entries(images).map(([key, value]) => (
						<div>
							<img src={`/me/${value}.jpg`} alt={key} />
							<p className="legend">{key}</p>
						</div>
					))
				}
			</Carousel>
		</div>
	)
}

export default HeroSlider
