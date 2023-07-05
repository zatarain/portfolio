import { Carousel } from 'react-responsive-carousel';
import Image from 'next/image';
import styles from './index.module.css'
interface Properties {
	images: object
}

const HeroSlider = ({ images }: Properties) => {
	return (
		<Carousel
			animationHandler="fade"
			autoPlay={true}
			showThumbs={false}
			showStatus={false}
			transitionTime={1000}
			interval={7000}
			showArrows={false}
			infiniteLoop={true}
			stopOnHover={true}
			swipeable={true}
			className={styles.hero}
		>
			{
				Object.entries(images).map(([key, value], index: number) => (
					<figure key={key}>
						<Image src={value} alt={`Image ${index + 1}`} width={1440} height={768} />
						<figcaption>Image {index + 1}</figcaption>
					</figure>
				))
			}
		</Carousel>
	)
}

export default HeroSlider
