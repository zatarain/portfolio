import 'react-responsive-carousel/lib/styles/carousel.min.css';
import { Carousel } from 'react-responsive-carousel';
import Image from 'next/image';

interface Properties {
	images: object
}

const HeroSlider = ({ images }: Properties) => {
	return (
		<div className="hero">
			<Carousel
				animationHandler="fade"
				autoPlay={true}
				showThumbs={false}
				showStatus={false}
				transitionTime={1000}
				interval={4000}
				showArrows={false}
				infiniteLoop={true}
				stopOnHover={true}
				swipeable={false}
			>
				{
					Object.entries(images).map(([key, value]) => (
						<div key={key}>
							<Image src={value} alt={key} width={1440} height={1080} />
						</div>
					))
				}
			</Carousel>
		</div>
	)
}

export default HeroSlider
